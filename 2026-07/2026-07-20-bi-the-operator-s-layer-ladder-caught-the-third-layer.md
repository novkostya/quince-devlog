# 2026-07-20 — (bi) the Operator's layer ladder caught the THIRD layer: unprivileged userns blocks FICLONE (`EPERM`) — mirror strategy RULED as a ladder with a host-side hook verb

(bi) **the Operator's layer ladder caught the THIRD layer: unprivileged userns
blocks FICLONE (`EPERM`) — mirror strategy RULED as a ladder with a host-side hook verb.**
The qn.5 session's mandated re-verification (OCI → LXC → host, exact production mount shape)
established: host shares fully (+4.3G bcloneused/saved, ALLOC flat); unprivileged LXC and
the OCI container inside it get `EPERM` — so in-container reflink is unavailable in the
recommended secure topology, and the session's original practical outcome (mirror costs a
copy) was RIGHT for the wrong reason, twice removed. Its confirmations were exemplary:
recomputed dataset-`used` predictions match all three original readings (the accounting trap
fully explains finding #2), EXDEV-from-snapshot reproduces at every layer. RULING (option 1
+ option 2 as fallback; 3 rejected on security posture — privileged topologies simply fall
out of the ladder naturally; 4 stays rejected per (bf)): the mirror ladder = (i) hook
present → new constrained **`mirror` verb** rebuilds `latest/` HOST-side where FICLONE
works (`cp -a --reflink=always` from `working/` under the job lock + atomic swap; children
of the parent only; touches only the derived `latest/`, never snapshots — bounded blast
radius since `latest/` is rebuildable); (ii) hookless → in-container reflink attempt with
the pool-level probe; (iii) hardlink-under-matrix; (iv) copy, surfaced. Stack D5 amended;
deploy/storage.md + the helper reference gain the verb (qn.5 folds); interface facts 1–2
close with the full three-layer evidence. Investigation arc complete: canon-vs-reality →
evidence-vs-instrumentation → layer-privilege; each round caught by a different mechanism
(gap protocol / Operator skepticism / the Operator's layer ladder).
