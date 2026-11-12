// lithium: deploy Logto database alterations exactly once per upgrade, however many pods (and clusters) start at the same time.
// Logto 1.x refuses to start with "Undeployed database alterations found" and its own `alteration deploy` is NOT safe to run
// concurrently (second runner: column "..." already exists). A Postgres advisory lock (session level) serialises the runners;
// the losers wait, then find nothing to do.
const { spawn } = require("node:child_process");
const pg = require(require.resolve("pg", { paths: ["/etc/logto/packages/cli"] }));
const LOCK = 727274; // arbitrary, fixed: "lithium"
(async () => {
  const c = new pg.Client({ connectionString: process.env.DB_URL });
  await c.connect();
  const t0 = Date.now();
  // NOT a blocking pg_advisory_lock(): a waiting session is inside a statement that holds a snapshot, and Logto alterations use
  // CREATE INDEX CONCURRENTLY, which waits for every older snapshot -> deadlock (found by test). Poll with try-lock instead.
  for (;;) {
    const { rows } = await c.query("select pg_try_advisory_lock($1) as ok", [LOCK]);
    if (rows[0].ok) break;
    await new Promise((r) => setTimeout(r, 1000));
  }
  console.log(`lithium-migrate: got the lock after ${Date.now() - t0} ms`);
  const t1 = Date.now();
  const code = await new Promise((r) => spawn("npm", ["run", "alteration", "deploy", process.env.LITHIUM_LOGTO_VERSION], { stdio: "inherit" }).on("exit", r));
  console.log(`lithium-migrate: alteration deploy ${process.env.LITHIUM_LOGTO_VERSION} exit ${code} in ${Date.now() - t1} ms`);
  await c.end();
  process.exit(code ?? 1);
})().catch((e) => { console.error("lithium-migrate:", e); process.exit(1); });
