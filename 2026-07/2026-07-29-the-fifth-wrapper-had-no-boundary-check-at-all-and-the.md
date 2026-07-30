# 2026-07-29 — The fifth wrapper had no boundary check at all, and the suspension everyone reasoned from stopped the credential working without stopping the message recruiting someone to…

**The fifth wrapper had no boundary check at all, and the suspension everyone reasoned
from stopped the credential working without stopping the message recruiting someone to recreate
it.** quince#232 closed by quince#233: `bin/gh-bot` — the legacy implementer wrapper — asserted
`approver ≠ author` *not at all*. Not a stale check naming a credential that had moved, which was
quince#204's defect one PR earlier; none. It was the only one of five forge wrappers that could not
refuse a second identity, and the omission survived every audit **because its four neighbours were
correct**: a suite thorough in one direction reads as thorough in all of them. **The issue was
filed on the argument that the hole was not live** — `quince-bot` was suspended on 2026-07-28, so
every call fails at GitHub whatever else the box holds — and that argument was the weak part of it.
The architect box measured why: `main`'s `gh-bot` there answers *"no bot token — place one"*, so a
session doing what the tool tells it places the implementer credential on the box already holding
the reviewer key and the architect token, **building the author-and-approve machine while following
an instruction**. Suspension disables the credential; it does not disable the recruitment. That is
quince#157's *"an environment refusal invites the wrong repair"* as a live property of a real box
rather than a principle — on that box, before the fix, the wrong repair was the **only** thing
offered. **Ruled by the architect** over documenting the hole (does nothing if the account is
restored) and over refusing unconditionally, which would have destroyed the artifact
`decisions/0014` condition 1 protects: a wrapper still runnable and still failing honestly is live,
checkable evidence, where a comment asserting the same is not. **The two-seat pattern is now the
finding, twice in two PRs and in the same direction both times.** On quince#231 the author could
show only that the guard was absent; the approving box showed it *exercisable*. Here the author
could offer only a negative control — the guard stays silent on a correctly provisioned implementer
box — and the approving box supplied the positive one. Neither half was reachable from the other
seat, by construction: the credentials are the thing being tested and no box holds both. **A
question that had outlived two PRs was closed by a grep in the neighbourhood.** quince#204's fourth
item — whether `deploy/runner/provision` makes this reachable by accident — was booked unproven by
quince#204 and again by quince#231; `provision` **places no credentials at all**, naming those
paths only to read them in one role-mismatch guard. Not reachable by provisioning; credentials are
placed by hand. The grep then produced quince#234, and it is **the third instance in one day of a
single shape**: that guard fires only when *this* role's token is absent AND the other's is
present, so a box holding both passes it — and it compares bot against arch only, knowing nothing
of either App key, which is to say it is a guard naming a credential set that moved underneath it,
exactly like quince#203 and quince#204. Guarded twice downstream by `preflight` and `gh-arch`, so
not live; recorded because three instances of one pattern in a day is the pattern, not the
instances. **What the RULING got wrong, and the attribution is the point:** its sizing note said the
PR should not grow to carry a second fix and then stopped — one sentence covering PR scope while
leaving *whether to file* unaddressed, from the seat whose rulings are meant to be unambiguous
instructions. The finding stayed in prose with nothing pointing at it, which is the precise decay
that let quince#204's fourth item survive two PRs. The architect filed it as quince#234 and
corrected the **note** rather than the reading: **filing is free and not in tension with sizing**,
and an owed item with no issue behind it is an owed item that will be owed forever. The author's
share is real and smaller than it first wrote: given a sentence that did not reach the question, it
supplied a default instead of asking, and the first draft of this entry recorded the whole thing as
a misreading. **The reviewer asked for that to be changed, which is why it is worth recording** —
*"the author should have read more carefully"* is advice nobody can act on, since every misreading
in this project's history looked reasonable from the inside, while *"a ruling conflated PR scope
with filing scope"* names a thing one seat can change about how it writes them. It is also the only
place this entry blamed a reader rather than an artifact, which is exactly what it faults `main`'s
`gh-bot` message for not doing.
([quince#233](https://github.com/novkostya/quince/pull/233),
[quince#232](https://github.com/novkostya/quince/issues/232),
[quince#232 ruling](https://github.com/novkostya/quince/issues/232#issuecomment-5122106999),
[quince#234](https://github.com/novkostya/quince/issues/234),
[quince#231](https://github.com/novkostya/quince/pull/231),
[quince#204](https://github.com/novkostya/quince/issues/204),
[quince#203](https://github.com/novkostya/quince/pull/203),
[quince#157](https://github.com/novkostya/quince/issues/157))
