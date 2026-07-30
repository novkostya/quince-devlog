# 2026-07-19 — (ah-qn1) qn.1 BUILT — the app frame stands

(ah-qn1) **qn.1 BUILT — the app frame stands.** Full `make gates`
(go + vault + ui), `make gates-ui-e2e` (Playwright stories 1–2), and `make image` green
in `quince-dev`. **Core** (`core/internal/{wire,config,store,auth,bus,ws,demo}` +
expanded `httpapi` + `id`): typed schema-v0 config with atomic canonical writes /
last-good-on-invalid / `quince config validate`; modernc SQLite (WAL) with embedded
migrations (`settings`/`sessions_auth`/`audit`); argon2id auth with first-run
set-password (one-shot **409** guard), session rotation, idle/absolute timeouts, per-IP
login rate limit, and double-submit CSRF; a race-clean event bus (drop-on-slow) + the
`/api/ws` handler (pre-upgrade auth + strict Origin, `hello` frame, ping keepalive); the
full REST read surface (devices/jobs/versions/config) golden-tested against contracts §2;
a security middleware chain (recover, CSP + frame denial, body limit, auth guard, CSRF
guard); and a `--demo` provider scripting device churn + a backup with a
silent-stall→recovery arc + every WS event type. **UI**: react-router auth-gated shell,
a WS bridge feeding Zustand stores with reconnect-backoff + GET-refresh, vendored
shadcn-style components on Radix, Dashboard / device-details / Settings pages on live
demo data, and a shared humanizer. **Operator rulings this rung** (also in the spec's
rung-ruled section + contracts §1): the auth endpoints (`/api/auth/status`, `/api/auth/setup`
with the 409 guard, double-submit CSRF) and adopting `react-router-dom`. Rung-local calls:
library set looked up live (yaml.v3 / modernc / coder-websocket / x/crypto / oklog-ulid;
zustand / TanStack Query / Radix), embedded-SQL migration runner, Secure-cookie-off in
demo (so http e2e/localhost login works), hardcoded admin-session timeouts (future
`auth:` config noted for qn.6), slog JSON/TTY, config exchanged as structured JSON,
golden fixtures via `make gen-golden`, and a two-container Playwright e2e target
(`gates-ui-e2e`, CI `e2e` job) using the official Playwright image. Not yet committed
(awaiting Operator). Next frontier: **qn.2**.
