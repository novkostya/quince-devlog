# 2026-07-24 — (db) ARCHITECT REVIEW of qn.6a ((da)): APPROVED + LANDED (main → `3a7b068`, ff-only). The rung chain is COMPLETE — the frontier is now the CODE FREEZE + PROCESS REVAMP, with the…

(db) **ARCHITECT REVIEW of qn.6a ((da)): APPROVED + LANDED (main → `3a7b068`,
ff-only). The rung chain is COMPLETE — the frontier is now the CODE FREEZE + PROCESS REVAMP, with
the app soaking on staging.** Verified in code, not just the report: both contract changes are
exactly the (cv) shapes (`missing` mapped in `toWire`, dead row = no size/no Unlock/Remove-on-
DELETE/never omitted; `seeding` between `preflight`/`backing_up` with `progress.phase` mirroring);
the engine split kept the load-bearing ordering (every preflight REFUSAL still precedes Seed —
nothing to discard on refusal); startup job-row reconciliation is complement-of-terminal, so a
daemon killed mid-`seeding` reconciles to `connection_lost` with no enumeration to update and the
Finding B guard owns the partial tree; `scanFrames` handles the `\r\n`-split-across-reads edge;
the client single-`is_latest` fix is correctly scoped per-device; `UDIDsWithVersions` includes
missing-only devices (history rendered dead, not forgotten) and a failed lookup degrades to empty
rather than blanking the live table; e2e story 5 asserts the real soak claims (overflow ≤ 1 px,
disabled-with-reason, seeding narration, dead row) at 390×844. Architect re-ran the privacy sweep
over the full branch diff (warranted — see deviation 1): clean, synthetic demo constants only.
**Ruling 1 — the state-vs-phase judgment call is ENDORSED and now canon:** (cv)'s "phase-enum
addition" wording was ambiguous between the `Job.state` enum and the open `progress.phase` string;
the implementer's reading — `seeding` as a full STATE — is ratified, for the implementer's own
reason (the card headline reads `job.state`; only a state makes the ruled narration the headline
during the ~23 s clone) plus one the report didn't claim: the state machine's running states are
consumed complement-of-terminal throughout, so the add is structurally free. **Two process
deviations recorded as REVAMP EVIDENCE, not blame:** (1) the branch was pushed to the PUBLIC
remote before architect review — the landing protocol has the architect land; a pre-review push
makes an unreviewed privacy leak irreversible in principle (this one was clean; the remote branch
is deleted post-land). The implementer flagged the push itself as unexplained ("wasn't in
protocol"), which is exactly the honesty the process wants. (2) The contract diffs were landed
with the build rather than proposed early for sign-off as the kickoff asked — functionally
mitigated here (the shapes were pre-ruled and the ONE ambiguity was flagged for review, which is
what early sign-off exists to catch), but the mitigation relied on the implementer's judgment,
not the process. Both join the friction pile: the revamp should make the landing/proposal
protocol MECHANICAL (a checklist the session can't drift past), not narrative. **Observation
banked for qn.7 (no action now):** `storage.Seed` takes no context — a cancel during a hung seed
waits on the 30-min backstop, not the job cancel; pre-existing shape (unchanged since qn.5b),
belongs with qn.7's liveness/chaos work. **Soak notes for the Operator:** redeploy staging from
main `3a7b068` (staging still runs the hardware-day build — it predates the Finding B guard AND
qn.6a); migration 0004 applies on first start; avoid changing the backup password mid-soak
(#9b, qn.7). **The daily-driver arc that began at (by) is DONE — qn.4c, qn.5, qn.5b, qn.6a all
landed; the app is soak-ready. Next session under a NEW process.**
