# 2026-07-20 — (bl) qn.5 folds the mirror-ladder ruling into code + docs

(bl) **qn.5 folds the mirror-ladder ruling into code + docs.** Implemented the
stack D5 (bi)/(bj)/(bk) ladder in `internal/storage`: the zfs `latest/` mirror now ALWAYS
clones from `working/` (never `.zfs` — EXDEV every layer), via **(i) hook `mirror` verb
(host-side reflink + atomic swap, touches only the derived `latest/`, reports SHARED/COPIED)
→ (ii) in-container reflink → (iii) hardlink-under-matrix → (iv) copy**, self-selecting by
risk dominance; an in-container reflink reports **UNVERIFIED** (no channel yet — statfs
`f_bavail` is a documented follow-up) and never takes the risky measured-not-sharing→hardlink
downgrade absent a channel; every mode + honest claim is surfaced (`MirrorReport` / logs /
`LastMirror()` for health). `deploy/storage.md` + the `quince-zfs-helper` reference gain the
`mirror` verb. Interface facts 1–2 closed with the three-layer evidence (block cloning works
at the POOL level but EPERMs in the unprivileged userns; FICLONE-from-snapshot is EXDEV).
`make gates-go` green (0 lint, race-clean; storage 78.7%); CI proves the fallthrough + the
hook-verb argv (fake hook), the reflink-shares + host-side-hook paths prove on the lab (gate
12). **Still uncommitted pending the Operator's ask** (the two CI-half commits stand). Remaining
gate-12 legs (Operator-driven): the host-side `mirror` verb on the real rpool, iMazing-opens,
syncoid mid-write, and the 12c destructive matrix (which validates the hardlink tier).
