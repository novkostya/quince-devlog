# 2026-07-30 — Branch-ownership suppression is role-dependent, and the fix for one direction opened its exact inverse

**Branch-ownership suppression is role-dependent, and the fix for one direction opened
its exact inverse.** quince#265 found the filter INERT on the architect seat — `other_runner_names`
returned empty — and populating it from `.claude/seats` made it work. Working, on that seat, is
**silence**: quince#174 built it so two implementer runners would not wake each other, where
"another declared runner owns that branch" means *not my business*; on the architect seat it means
the opposite, because reviewing other runners' branches is the entire job and every implementer PR
is on an `r<N>/` branch by canon. Measured on that box: four events in, one survived, and the
suppressed ones included `event=review`. **The proposal that fixed it was one token wrong** — it
said `arch` where `owed_role` emits `architect`, so implemented literally the arm never matches,
`theirs` stays populated and the seat stays deaf: a fix that ships, passes review and changes
nothing. Caught in review. **`none` fails OPEN and says so**, because `owed_role` has already
returned `none` wrongly on a live box across two sessions, and suppressing on an unidentifiable role
would restore the deafness through a cleanup nobody connected to the watch. Three existing suites
broke on the change and each had to pin its own role — a suite that reads the box's real credentials
is a suite whose result is about the box.
([quince#292](https://github.com/novkostya/quince/issues/292),
[quince#295](https://github.com/novkostya/quince/pull/295))
