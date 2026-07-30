# 2026-07-22 — (cj) architect rulings on (ci)'s four PROPOSED rows + #9 (the audit itself: approved, and the #4/#5 "a redesign deletes the bug" subsumption is the model catch)

(cj) **architect rulings on (ci)'s four PROPOSED rows + #9 (the audit itself: approved,
and the #4/#5 "a redesign deletes the bug" subsumption is the model catch).** **#6 (failed newest
attempt is invisible — card shows only last *success*) → qn.6a, and UPGRADED to CORE, not
optional.** This is the direct consequence of the (bz) decision to make `last_backup` mean last
*success*: correct, but it *created* the duty to surface a failed newest attempt elsewhere or
failures go invisible — and **a soak whose failures are invisible is a worthless soak**, so it is
load-bearing for qn.6a's charter. Shape: a "needs attention · Retry" companion line, not a
mutation of `last_backup`. **#7 (two `latest` badges until reload) → qn.6a** (client-store fix:
mirror the server's single-`is_latest`-per-device invariant when applying `version.*` events —
pure UI). **qn.5b re-confirms the SERVER invariant still holds after its commit reorder**, but
the client fix is UI and stays out of the storage rung. **#8 (Wi-Fi drop → `failed` not
`connection_lost`) → qn.7 CONFIRMED** — it is transport-loss *classification* + the interface-fact-2
correction (a drop has two shapes: the stall quince handles, and the clean receive-error exit it
mislabels), squarely qn.7's chaos-suite/liveness domain, fixture-first beside the stall fixture.
**Soak guard:** qn.6a's UI pass must present whatever terminal state honestly so a *bare* "failed"
doesn't read as data loss during the soak — the outcome was SAFE (work discarded, `latest/`
untouched); the label is what's wrong. **#10 SPLIT CONFIRMED** — honest byte-labelling (current-file
bytes shown as the *backup* total is a lie) → qn.6a, riding #3's `SplitFunc`; percent-from-cumulative
smoothing + the liveness note firing during a large-file receive → qn.7 (progress/liveness shaping).
**#9 RULED (the substantive one): SPLIT.** **(a) honest `kind` (full vs incremental) → qn.5b** —
don't heuristic it in `verify.go` off the unreliable `IsFullBackup` flag; under qn.5b's per-job
`working/` model quince *authoritatively knows* full-vs-incremental, because it IS whether `working/`
was seeded from an existing `latest/` (incremental) or started with none (a first/full backup). The
honest signal falls out of the seed decision qn.5b already makes — more correct AND cheaper than a
Status.plist heuristic; a genuine tightening, not scope creep. **(b) force `--full` after an
encryption change → qn.7 (correctness/hardening), with a SOAK CAVEAT recorded now:** an incremental
built on a prior version encrypted under a *different* keybag can be inconsistent, so during the soak
either avoid changing the backup password, or **Reset** (the landed `RepairWorkingCopy`, surfaced by
qn.5b) after an encryption change to force the next backup full. qn.7 automates the force; the interim
mitigation already exists. That (b) is real correctness, not cosmetics, is why it is flagged rather
than parked silently.
