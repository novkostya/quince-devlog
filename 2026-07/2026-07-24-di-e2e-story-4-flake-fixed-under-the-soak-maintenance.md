# 2026-07-24 — (di) e2e story-4 FLAKE fixed under the soak-maintenance lane ((dd)) — a test-only change; two distinct bugs, diagnosed honestly, neither a UI defect

(di) **e2e story-4 FLAKE fixed under the soak-maintenance lane ((dd)) — a test-only
change; two distinct bugs, diagnosed honestly, neither a UI defect.** CI run `30108238903` (job
`e2e`, on main `c5a7776` — a DOCS-ONLY commit; the prior run on identical code was green → flake,
not regression) failed `story4-backup-now.spec.ts:22` two different ways across the attempt + its
Playwright retry. **Bug 1 — strict-mode violation at the second cancel assertion:**
`getByText(/backup cancelled/i)` resolved to 2 elements. Traced to source, NOT a double-render:
both are legitimate `JobHistory` intent-group summaries (`groupByIntent` → "Backup cancelled"),
and by that point the test has cancelled TWO jobs — the retried seed-intent and the fresh
backup-now intent — so two groups honestly read cancelled (DeviceCard, the other suspect, isn't
even mounted on the details page). It flaked rather than always-failed because `wire.Now()` is
second-precision RFC3339, so the assertion sometimes fired in the window before the 2nd cancel
re-rendered (1 match) and sometimes after (2 → strict violation). **Fix:** assert on the COUNT
delta of an EXACT-text locator (`getByText("Backup cancelled", { exact: true })` — the capital-B
summary, excluding the lowercase "backup cancelled" job-log line) via `toHaveCount(before+1)`.
Count-delta is (a) immune to the newest-first ordering tie on a shared whole-second timestamp,
(b) never trips strict mode with >1 cancelled group, (c) transient-tolerant (it polls to the
settled value rather than hard-failing on a momentary 2, which is exactly what bare `toBeVisible`
could not do). **Bug 2 — `retry-backup` absent on Playwright retry #1:** test-idempotence. The e2e
demo server is SHARED and never reseeds per test, so the failed primary attempt already advanced
spare-iphone's latest intent past the one-shot seeded `connection_lost` backup; Retry (latest-
intent-only since qn.6a) is gone by the retry. **Fix:** guard the retry leg on
`testInfo.retry === 0` — the primary attempt always runs against a fresh container (pristine seed)
so it HARD-asserts the Retry affordance (regression guard preserved, coverage undiminished on
every normal run); a genuine Playwright retry skips the now-invalid precondition and still
exercises the backup-now/cancel leg. **Surface:** `ui/e2e/story4-backup-now.spec.ts` only (+30/−10);
no engine/httpapi/ui-src/internal-demo change — deliberately, since qn.6b builds the engine/deploy
surface in a parallel worktree (its uncommitted `internal/backup/backup.go` + `deploy/Dockerfile`
were confirmed untouched). **Verification** (isolated dev CT `pct clone`d off qn.6b's box, per the
one-project-one-CT rule): story4-test1 ×10 against a fresh seed with `--retries=0` → **10/10**
(bug 1 gone under the strictest setting, no retry masking); a forced primary-fail against a
consumed seed with `--retries=1` → primary fails on the absent Retry, Playwright retry recovers →
**exit 0** (bug 2 guard proven end to end — old code would fail both attempts); full e2e suite ×3
fresh containers → **9/9** each (no collateral breakage); **`make gates` green** (go `-race` all
ok + golangci 0 issues, vault ruff/`mypy --strict`/pytest, ui typecheck/eslint/vitest 55·55/build).
The run's 429 action-download backoff annotations were infra noise (recovered), not the failure —
ignored per the brief. **Process:** soak-maintenance ((dd)) — CI-green + architect review + this
letter, no spec/report ceremony; branch `claude/e2e-story4-flake`, NOT pushed (architect verifies
via PR-triggered CI and lands ff-only); whole-diff privacy sweep clean. **Friction / revamp
evidence:** (1) the shared long-lived `--demo` server is a good fidelity choice but has no per-test
reset, so any test that CONSUMES a one-shot seeded precondition is non-idempotent under a
Playwright retry — the clean fix (a demo reseed endpoint the e2e can call in `beforeEach`) was
out of surface here (needs httpapi, which qn.6b owns); the revamp should decide whether the demo
provider grows a test-only reset so retry-idempotence stops living in per-test guards. (2) Two
parallel sessions sharing one dev box is a real hazard — `quince-dev` (CT 110) held qn.6b's
uncommitted engine diff, so a whole-tree rsync would have clobbered it; the lane needs an explicit
"which CT is mine" rule for concurrent work (this fix used a throwaway clone, CT 116).
