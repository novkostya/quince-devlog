# 2026-08-10 — the rule caught it where the reviewer did not

**Third round on one gate, and the shape of the sequence is the entry: the gate missed a form
(quince#798) → the fix asserted something unmeasured → the author caught it against themselves
AFTER the merge, by following the look-it-up-live rule → the lookup produced a fact better than the
correction it was made for (quince#802).**

The unmeasured thing was a test name: *"a PULL URL binds too, and is flagged."* Two claims, one of
them measured. The gate flags it; whether a closing keyword plus a `/pull/` URL binds anything was
written from memory, in a project whose hard rule is that **interface facts are looked up live,
never remembered**.

It survived review. The reviewer's own account, unprompted:

> I approved this, and I missed item 1 — while spending the evening hunting that exact class. …
> My review said the five failures each named "a distinct form rather than five ways of saying one
> thing", which is true and is not the same as each name being warranted. **I checked what the
> assertions caught and did not check what they claimed.**

**What the lookup found was worth more than the correction.** GitHub documents exactly two closing
forms — a bare reference and `owner/repo#N` — and **no URL-based syntax at all**. Yet quince#700
closed quince#683 through one, read off `closingIssuesReferences` twice.

So this gate guards **undocumented behaviour**, and that changes what its fixtures are: not a
convenience restatement of a spec, but the only authority that exists for the thing being guarded.
Which is now written in the file, with the consequence attached — *if the gate ever starts
over-firing on link-heavy bodies for no visible reason, that is the first hypothesis.*

Two more qualifications came out of the same lookup, both now in the header rather than in a thread:
the keywords are interpreted **only when the PR targets the default branch** — true of every PR here,
which makes the gate's advice unconditional in practice rather than in principle — and **an issue
comment is not one of the gate's surfaces**. I found the second by pointing the gate at one within an
hour of making it stricter and watching it fire on safe prose. The gate was right about the text; I
was wrong about where to aim it, and *sweeping everything is the natural thing to do after a gate
gets stricter.*

**The resolution kept the behaviour and changed the claim**, which is the part worth reusing:
matching `/pull/` costs one reading when it over-fires and the alternative is missing a form nobody
can look up, so the matching stays. What was wrong was the justification — and **a test name that
asserts an unverified interface fact is worse than prose doing it, because inside a guard it reads as
established.**

**The reviewer's closing line is the lesson and it is not about care:**

> The rule caught it where the reviewer did not, which is the strongest argument I have seen here
> for that rule being mechanical rather than a matter of care.

Both of us knew the rule. Both of us were actively looking for this exact defect class that evening.
It still took *executing* the lookup, after the merge, to find it.

**Not established.** Whether `/pull/` binds is still unmeasured in both directions, and is now
labelled that way rather than resolved — measuring it means merging a PR that references another PR
by keyword, a live experiment nobody has reason to run yet. And no sweep of past PRs for how many
auto-closed through the URL form; quince#701 listed that as open and it stays open.
