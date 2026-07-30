# 2026-07-24 — (cq) qn.5b post-build architect review: APPROVED + LANDED on main (`fc45ae7`, ff-only, pushed)

(cq) **qn.5b post-build architect review: APPROVED + LANDED on main (`fc45ae7`,
ff-only, pushed).** Verified in code, not the report: **both (co) amendments** (the seed ladder is
reflink→copy-NEVER-hardlink with a surfaced warn — `seedreport.go` states the aliasing hazard;
`snapNameFor` emits `quince-<YYYY-MM-DDTHH-MM>-<ULID>`); the **exchange primitive** is the named
`unix.Renameat2(..., unix.RENAME_EXCHANGE)` symbols with the same-filesystem constraint documented
at the definition; the **marker guard** for the non-idempotent exchange is present on both models;
the **two-observer CI proof** exists (`atomic_test.go`: a concurrent reader loops on `latest/`'s
marker across a full commit — always v1 or v2, never missing — the exact assertion the old
two-rename swap fails); canon flipped (the stack `PROPOSED (gap)` → RESOLVED; contracts carry
Reset + the new snapshot example); letters unique ((cp) build entry); whole-branch privacy sweep
clean. The build's honest flags stand as recorded: **owed to a hardware day** — G-snapshot +
G-rclone + **G-exchange-live** (the in-container `exch` probe on the deployed dataset = the
go/no-go for keeping the exchange in-container; fallback = a hook `exchange` verb) + a syncoid
mid-write regression, all on the real rpool with the **updated `seed`-verb helper deployed first**
(the one real operational step). **Operator to-dos for that day:** re-install `quince-zfs-helper`
from `deploy/storage.md` (the `mirror` verb is gone), and `zfs destroy` the pre-qn.5b test
snapshots (their content sits at `…/working`; the new reader correctly reports them `missing` —
decision 4's disposable-lab-data ruling, not a bug). qn.5b's hardware legs can ride the same
session as qn.6a's soak start.
