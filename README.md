# dpoc-aldehyde.lithium

Logto 1.46.0 as the identity issuer of a landscape (`lithium` service of platform `aldehyde`).
NO own source code: the image is `ghcr.io/logto-io/logto:1.46.0` plus a wrapper entrypoint.

- Issuer `https://lithium.aldehyde.<landscape>.<first root>/oidc`, admin `https://admin.aldehyde.<landscape>.<first root>`.
- One issuer per landscape; the app chart runs **2 replicas per cluster** (raichu: 2 clusters -> 4 replicas on one database).
- `entrypoint.sh`: reads `/deps/database-main/secret.json` (mounted, NOT optional -> the pod waits for T3's Secret),
  builds `DB_URL` from the direct (non-pooled) host, runs `npm run cli db seed -- --swe --encrypt-base-role` (idempotent; retried because two
  clusters can start at once), then `npm start`.
- Registered apps, APIs, the sign-in experience, the bootstrap M2M and the test user are NOT done here: T3's logto
  controller does them through the Management API (the boot M2M row is inserted by SQL by T3).

## Layout
- `Dockerfile`, `entrypoint.sh`
- `infra/app` chart `dpoc-aldehyde-lithium` (Deployment/Service/Ingress; `landscapes/<l>.yaml`)
- `infra/primordial` chart `dpoc-aldehyde-lithium-primordial` (one `Database` record, Neon, the landscape's region)

## Release
Push a tag `vX.Y.Z` (secret `DPOC_REG_PASSWORD` must exist). The workflow pushes image
`reg.dpoc.specpenguin.dev/dpoc-aldehyde-lithium:X.Y.Z`, then the primordial chart, then the app chart (LAST).
