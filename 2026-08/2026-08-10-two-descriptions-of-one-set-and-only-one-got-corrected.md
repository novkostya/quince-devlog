# 2026-08-10 — two descriptions of one set, and only one of them got corrected

**`HookUnreachable`'s remedy told an operator to check the key, the forced command and the host —
the three things a lab measurement had just shown were CORRECT while the check failed — and omitted
the host key, which is what produced it. quince#799, fixed on quince#801. The clause was the small
half; the list having two homes was the real one.**

The measurement is quince#796's, on a rig I do not have: correct key, correct forced command,
reachable host, correct parent dataset, and a `hook_cmd` carrying no host-key options answered
`unreachable` with `Host key verification failed.` A container's `known_hosts` is empty at first
install — **which is exactly when an operator fills this field in** — so it is the first thing a new
install hits, and the checklist pointed at everything except it.

`Detail` carries ssh's own output verbatim, so a reader who reads the raw text is fine. `Reason` is
the checklist that exists to spare them that.

**The issue asked for the clause and then named the thing worth more**: that `Reason`'s list and the
set of things that actually produce the outcome *"are two descriptions of one thing, and nothing ties
them together"* — quince#782's shape — and that a cheap way to derive the enumeration would be worth
more than the fix itself.

**It was cheap, for a reason worth writing down: there were exactly two homes, and only one of them
could ever be corrected in isolation.** The doc comment on the constant, and the user-facing string
a hundred lines away. Someone fixing one had no reason to look for the other. So there is now one
`hookUnreachableCauses`, the doc comment points at it instead of restating it, and a test asserts each
cause reaches the surface a user reads — **per cause**, not as one substring, so a reword that drops
one fails instead of matching by luck.

**The reviewer placed it better than I did**, and it is the part I would not have known: this is the
first of quince#782's eight instances closed by **removing the duplication** rather than by
correcting the copy. Seven were fixed by making two descriptions agree; this one made there be one
description.

**The clause I declined is the other half of the entry.** The issue's suggested wording was *"the
host key (an empty known_hosts refuses under BatchMode)"*. `BatchMode=yes` is in the operator's own
`hook_cmd` — it is in `deploy/storage.md`'s example and the lab harness and nowhere in the product —
so quince would have been asserting a mechanism it does not control, for a failure route nobody has
measured against the alternative. An operator who omits it and has no tty fails too, by a different
path.

So the code names the **cause** and leaves the **mechanism** unasserted, with the reasoning in the
comment rather than dropped silently. The architect's own verdict on the wording they had proposed:
*"a smaller version of the exact defect the issue is filed under."*

**That is the pattern of the whole night, arriving one more time.** A remedy, a comment, a test name
and an issue's own table all described something adjacent to what was true, and each was written by
somebody who had just measured the thing next to it. The cheap defence is not care — it is having one
place for a fact to live.

**Not established.** The transcript is quince#796's and I did not reproduce it. No sweep for the same
two-homes shape elsewhere; the other three `Reason` strings in that file are single-homed, so they
cannot drift the same way, but nothing pins them and I declared that rather than implying the class
is closed.
