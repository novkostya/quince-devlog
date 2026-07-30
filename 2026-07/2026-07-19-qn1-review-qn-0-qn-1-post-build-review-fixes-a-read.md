# 2026-07-19 — (qn1-review) qn.0/qn.1 post-build review + fixes. A read-only conformance review (specs + frozen contracts §1–§6 + design §6) found no blocker/major

(qn1-review) **qn.0/qn.1 post-build review + fixes.** A read-only conformance
review (specs + frozen contracts §1–§6 + design §6) found **no blocker/major** — both rungs
conform and the security baseline is sound — plus a tail of minors. Top items fixed this
pass (full `make gates` + `make image` + `make gates-ui-e2e` re-green): (1) `GET
/api/jobs/{id}/log` (frozen in contracts §1) was unrouted — now served `text/plain` via
`JobReader.JobLog`, demo-backed by a per-job log ring buffer, and the UI recovers a running
job's log tail on WS reconnect (the `job.log` stream isn't replayable — closes the story-2
hole); (2) the demo now emits `device.updated` on backup success (refreshing `last_backup`),
so every §3 WS event type fires end to end and the device card no longer goes stale; (3) a
demo fixture set `last_backup.job_id` to a version id, not the job id (golden regenerated);
(4) auth hardening — `verifyPassword` now rejects an empty-key hash (was fail-open via
`ConstantTimeCompare` of two empty slices) and the login rate-limiter sweeps stale per-IP
buckets so the map can't grow unbounded; tests cover all three. **Deferred (logged, not
blocking):** WS session re-validation on logout/idle-expiry, DSN-scoped SQLite pragmas, a
`.dockerignore`, and assorted nits. Frontier unchanged: **qn.2**.
