# 2026-07-20 — (bu) decisions-log letter hygiene (two collisions in one review — a process fix)

(bu) **decisions-log letter hygiene (two collisions in one review — a process fix).**
Concurrent appenders (architect + a hardware session + a build session) each guessed "next
letter" and produced duplicate `(bp)` then `(bs)`. Rule going forward: **letters are cross-reference
anchors, not sequence guarantees** — on a collision, the *unreferenced* side renumbers to the next
free letter (grep `^- 2026-07-20: (b?)` first) and leaves a one-line breadcrumb; the *referenced*
side never moves (churns canon + code). A build/close record out of strict alpha order is fine — a
reader follows references, not the alphabet. (Fixes this session: (bp)-dup → the qn.4a build record
became (bt); (bs) stayed the gate-15 entry that owns it.)
