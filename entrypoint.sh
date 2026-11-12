#!/bin/sh
# lithium wrapper entrypoint: /deps/database-main/secret.json -> DB_URL, idempotent seed (retry), then start.
set -eu
F="${DB_SECRET_FILE:-/deps/database-main/secret.json}"
if [ ! -s "$F" ]; then echo "lithium: database secret $F missing or empty" >&2; exit 1; fi
# Direct (non-pooled) host: Logto runs transactions + advisory locks, which a pooler in
# transaction mode can break. The secret may carry a pooler host; strip "-pooler" from the first label.
DB_URL="$(node -e '
const s = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const host = s.hostDirect || String(s.host).replace(/-pooler(?=\.)/, "");
const e = encodeURIComponent;
process.stdout.write("postgres://" + e(s.user) + ":" + e(s.password) + "@" + host + ":" + (s.port || 5432) + "/" + e(s.database) + "?sslmode=require");
' "$F")"
export DB_URL
# Two clusters of one landscape can start at once and race on the first seed (it runs in one
# transaction, so the loser fails cleanly); --swe makes every later run a no-op. Retry.
i=0
# --encrypt-base-role: Neon rejects creating the tenant base role without a password (DDL forwarding "no password assigned").
until npm run cli db seed -- --swe --encrypt-base-role; do
  i=$((i + 1))
  if [ "$i" -ge 15 ]; then echo "lithium: seed failed $i times" >&2; exit 1; fi
  echo "lithium: seed attempt $i failed, retrying" >&2
  sleep $((2 + i % 4))
done
exec "$@"
