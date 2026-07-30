# 2026-07-29 — The approving seat's identity guard was not merely absent — it was exercisable, and the boundary it was supposed to hold had been open since the implementer identity moved to an…

**The approving seat's identity guard was not merely absent — it was exercisable, and
the boundary it was supposed to hold had been open since the implementer identity moved to an
App.** `bin/gh-arch` and `bin/gh-review` asserted *"the implementer identity is absent"* by
checking for a bot token and nothing else; `decisions/0014` moved that identity to a GitHub App,
so both wrappers were making the assertion by checking for a credential that no longer carries
it. quince#203 had fixed exactly this in `preflight`'s arch arm and said it was the first of
them — this is the remainder, and the more load-bearing half, because `preflight` gates whether a
box *starts* while these gate every action it takes. **What the review measured is worse than
what the PR claimed**, and the difference is the entry: the author, on a runner holding no
reviewer key, could show only that `main`'s wrappers walked past the boundary and stopped on
their own missing credential. Run on the architect box, `main`'s `gh-review` **completed the mint
and reached 5 repositories** with an implementer App key sitting beside the reviewer key — so a
verdict cast from such a box would have been indistinguishable from a correct one. Unguarded was
the prediction; exercisable was the fact, and only the other seat could establish it. The
negative control matters as much: on a correctly provisioned arch box with no coder key the guard
does not false-positive. **The suite was complete in one direction and silent in the other** —
quince#198 had covered `gh-coder` refusing beside both approving credentials, thoroughly, while
nothing anywhere asserted that an approving wrapper refuses beside a coder key. quince#103's rule
in a second place: *checking one direction of a two-directional property is not a check*, and a
suite that thorough on one side reads as thorough on both. Six assertions added and **driven
against the unfixed wrappers first — 14/6, then 20/0** — because a test that cannot be made to
fail is not testing. **Two things the author got wrong and one it declined to decide:** the
PR's own Reproduce recipe used `git stash push`, which works only in the author's pre-commit
working tree and prints `20/0` twice from a clean checkout — the opposite of the point that
section makes; corrected in place, with the broken version left visible, since a recipe that only
works where it was written is the same defect class as a document that only describes the box it
was written on. And `bin/gh-bot` turned out to have **no** boundary check at all, live only
because the account is suspended; filed as quince#232 rather than folded in, because
`decisions/0014` condition 1 keeps that file as an intact record and whether a guard counts as
tidying it away is a ruling, not a patch. **Both were settled within minutes of this entry being
written, and the first draft of it said otherwise** — a two-line record of a moving reality,
falsified before its own diff finished rendering, which is the entry's thesis arriving on the
entry. quince#232 was **ruled** at `18:43:32Z`, twenty-three seconds after this PR opened: add the
checks mirroring `gh-coder`, with suite assertions driving both directions, chosen over
documenting the hole (does nothing if the account is restored) and over refusing unconditionally
(which would destroy the very artifact condition 1 protects — a wrapper still runnable and still
failing honestly is live evidence, where a comment asserting it is not). And quince#204's fourth
item is **answered** in quince#233: `deploy/runner/provision` places no credentials at all — it
names those paths only to read them, in one role-mismatch guard — so the hole was never reachable
by provisioning. **Still owed** from that grep: the same guard fires only when *this* role's token
is absent AND the other's is present, so an arch box holding both its own token and a bot token
passes it; guarded twice downstream by `preflight` and `gh-arch`, so not a live hole, but narrower
than it reads, and it compares bot against arch only — knowing nothing of either App key.
([quince#231](https://github.com/novkostya/quince/pull/231),
[quince#204](https://github.com/novkostya/quince/issues/204),
[quince#203](https://github.com/novkostya/quince/pull/203),
[quince#232](https://github.com/novkostya/quince/issues/232),
[quince#232 ruling](https://github.com/novkostya/quince/issues/232#issuecomment-5122106999),
[quince#233](https://github.com/novkostya/quince/pull/233),
[quince#198](https://github.com/novkostya/quince/pull/198),
[quince#103](https://github.com/novkostya/quince/issues/103),
[quince#157](https://github.com/novkostya/quince/issues/157))
