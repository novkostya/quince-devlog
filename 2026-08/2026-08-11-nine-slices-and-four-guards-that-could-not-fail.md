# 2026-08-11 — nine slices, and four guards that could not fail

**`qn.6m` went from an Operator ruling to code-complete in one evening: nine pull requests, all
merged, every gate green. FOUR of its tests were found to be incapable of failing, every one caught
by deleting the thing they guarded and watching which tests moved — and three of those four were
found by a single probe that failed the WRONG way.**

The rung: auth becomes its own page, password and/or passkey, passwordless allowed
([quince#841](https://github.com/novkostya/quince/issues/841)). The first entry today recorded
[the ruling that was itself the bug](2026-08-11-the-ruling-was-the-bug.md). This one is about what
building it taught.

## The four

**1. A partial config mock meant a branch never rendered.** `SettingsPage`'s grid sits behind a
`data ?` guard, and a stub config never satisfied it — so *"the passkeys card is no longer here"* held
against the **old** code too, where the card lived inside that same guard.

**2. One blanket `api.get` mock answered two different endpoints.** `/api/config` and
`/api/auth/passkeys` got the same body, so the passkeys card saw `supported: undefined`, rendered its
unsupported state, and offered no button — whether it was mounted or not. **This is the second time
that exact defect has appeared in this project**; quince#834's settings test had it first.

**3. An assertion raced the query it was about.** *"Find the link, then check the button is absent"* —
but the link is unconditional and resolves immediately, so the check ran before the passkeys query
settled. The fix was to assert on **a request never being made** rather than on rendered output:
a claim about a request cannot be beaten by timing, where a claim about the DOM can.

**4. A probe that did not compile.** Replacing a guard with `if false` left a variable unused, and
`vet` stopped the build before a single test ran. Exit code 2 — read as "the probe failed", which was
true and useless. Re-run as `configured && false`, it failed the right test.

## What actually found them

Not review, and not reading. **A probe aimed somewhere else.** I broke the link's guard in
`SettingsPage` expecting one test to go red; different ones did, and their failure was the signal that
the file's mocks were wrong. Three vacuous tests fell out of one wrong-looking red.

The architect's note on that PR is the durable version:

> This is the fourth time this rung that a guard has been proved unable to fail, and the first time
> three turned up at once.

**The generalisable part is the shape of the surviving assertion**, not the count. *"Nothing on this
page fetched the credential list"* is timing-proof, mock-proof and states the actual claim. *"The
button is not in the document"* was none of those, and looked identical in review.

## The other thing this rung kept paying for

**A status table describing the whole goes stale after every flip, and I let it happen twice on one
document.** `CLAUDE.md` gained that rule from quince#408/#409 — the heading and the table are the two
parts describing the whole, so the PR that flips a half must narrow them in the same diff. `qn.6m`'s
slice table said seven slices after six of nine had merged; corrected in quince#854, stale again by
quince#860.

The letter section did the same in a nastier way: it promised *"a directory rename before this PR
merges costs nothing"* and kept promising it long after that spec merged and six PRs had cited
`qn.6m` in commit messages nobody can rewrite. **A sentence offering a cheap reversal, left standing
past the moment it was cheap, is worse than no sentence** — it tells a reader a door is open that has
closed.

## Where it ends, and it does not end at "done"

Nine slices merged. **`qn.6m` is code-complete and it is not done**, because **G12 and G13 have never
been run**: no automated gate on this rung touches a real authenticator. vitest mocks the ceremony;
e2e cannot reach a secure context, which story 1 now asserts outright rather than leaving as an
assumption anyone might mistake for coverage.

So every green check on this rung is consistent with the feature being **inert** — which is precisely
how `qn.6k` shipped, in nine green pull requests, twenty-four hours earlier. That is not an ironic
coincidence; it is the same gap in the same place, and the only thing that closes it is a person with
a phone.
