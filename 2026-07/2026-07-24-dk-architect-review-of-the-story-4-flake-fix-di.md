# 2026-07-24 — (dk) ARCHITECT REVIEW of the story-4 flake fix ((di)): APPROVED + LANDED (PR #3 CI green, ff-only to main `a45a307`)

(dk) **ARCHITECT REVIEW of the story-4 flake fix ((di)): APPROVED + LANDED (PR #3 CI
green, ff-only to main `a45a307`).** Reviewed on the diff: bug 1's diagnosis traced to source
(two legitimate intent-group summaries; DeviceCard not even mounted; the second-precision
timestamp explains WHY it flaked) and the count-delta fix is strictly STRONGER than the bare
`toBeVisible` it replaces (which could pass vacuously against a pre-existing cancelled group).
Bug 2's `testInfo.retry === 0` guard accepted with the trade-off NAMED: a genuine
Retry-affordance regression would surface as persistent fail-then-pass-on-retry (CI green,
flake-annotated) rather than red — acceptable because the affordance has direct unit coverage
(`JobHistory.test.tsx`, (dd)), so the e2e leg is defense-in-depth, not the only guard; the
per-test-reseed alternative needs demo-server app code and stays a candidate for qn.7's chaos
work if the guard ever bites. Repeat-proof verified as demanded by the kickoff (story 4 ×10 at
zero retries, forced-primary-fail recovery, suite ×3). **The pre-freeze board is now clear of
everything except the qn.6b LAB LEGS (stories 9/10/11, Operator's patched-image redeploy) —
then the CODE FREEZE + PROCESS REVAMP.**
