# 2026-07-24 — (cx) (cu) ELABORATED with the Operator — the raw-latency mechanisms banked as a parked, evidence-gated roadmap block (Later/parked)

(cx) **(cu) ELABORATED with the Operator — the raw-latency mechanisms banked as a
parked, evidence-gated roadmap block (Later/parked).** The Operator proposed a concrete scheme for
(cu) option (2): a cheap stand-in target so idevicebackup2 handshakes (and fires the passcode
prompt) immediately, the real seed running in parallel, `RENAME_EXCHANGE` swapping the seeded tree
in when ready. Architect checked the idevicebackup2 source rather than guessing: the facts are
FAVORABLE (pre-request it only stat/reads+rewrites `Info.plist`, remove-then-create so
alias-safe; manifests are read post-request via `DownloadFiles`; the iOS 16.1+ passcode wait
fires before the message loop; no long-lived fds — per-message `fopen`, so a mid-run exchange is
coherent). The Operator's "probing rw too early" caveat mostly dissolves, and "mark it readonly"
is the wrong tool (it breaks the legitimate Info.plist rewrite; the safe shape is a stand-in with
copies of the four control files and NO shard aliases). **The real hazard is the LOST RACE:** a
swap landing after the first write-class device message discards device-uploaded data into the
doomed stand-in — a version missing blobs, Finding B's failure mode by another road; plausible on
a tiny incremental (seconds of transfer vs ~23 s seed). So: a dedicated rung with a spike leg, if
ever. **Architect's challenge, accepted into the bank:** option (3) pre-seed-after-commit achieves
the same ideal UX with ZERO concurrency — the staleness objection is empty (`latest/` never
changes between commits), costs are the clean-snapshot invariant (bought for cleanliness, not
correctness) + copy-backend disk (gate to `SHARED` seeds) — and dominates the stand-in scheme on
risk-per-UX; the stand-in wins only if the invariant is ruled non-negotiable. **Ruling
(Operator-agreed): sequence unchanged** — qn.6a `seeding` phase now → soak → only if the raw wait
(not its visibility) is the complaint, rule between (3) [architect's lean] and the stand-in rung.
Both candidates + the source-verified facts live in the roadmap's Later/parked block so nothing is
re-derived from scratch. Interface-facts rule applies: re-verify against the VENDORED build before
building either.
