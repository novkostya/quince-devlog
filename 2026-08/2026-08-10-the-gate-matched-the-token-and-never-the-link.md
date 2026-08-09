# 2026-08-10 — the gate matched the token and never the link

**`closing-refs-check` exists to stop an accidental auto-close, and it reported `clean` over a PR
body that closed an issue. It matched the reference TOKEN and never the LINK — `grep -c github.com`
over it returned 0. quince#701, fixed on quince#798. Then the fix's own claim about the `/pull/`
half turned out to be unmeasured, and the hard rule that catches that is the one I broke.**

The measurement is the whole argument, and it is the same file through both versions of the gate:

```
gate at origin/main   → exit 0   "clean — no bare closing reference, and none bound to nothing"
gate on the branch    → exit 1   CLOSING REFERENCE, line 3
```

against quince#700's real body, which closed quince#683 — read off `closingIssuesReferences` rather
than inferred from the merge.

**The defect was coverage by coincidence, not a narrow pattern.** Two link shapes appeared to be
caught, and both were caught only because a human happened to put a reference in the link **label**.
Relabel it — `Fixes [the storage rung](<url>)` — and the gate went silent while the URL still bound.
That case had no coverage at all, and it is why this could not be fixed by widening the token
pattern: there is no token to widen.

**A correction to the issue's own table, which the architect then confirmed independently.**
quince#701 records the markdown-link form as exit 1 / *"BOUND TO NOTHING"* — misleading, but noisy.
On quince#700's actual body it was **exit 0, clean**. Both are right for different line shapes: the
inert check is line-initial, and that body has the keyword mid-line after a bold sentence, so nothing
matched at all. The recorded instance was the plain false negative, not the misleading message —
worth correcting because the table is what a reader plans against.

**And the message that WAS misleading was wrong in the expensive direction.** `inert_hits` called a
URL-bearing line *bound to nothing*. It binds. A session wanting to reference without closing reads
that, believes the merge is safe, and the issue closes anyway.

---

**The part worth more than the fix: I asserted a GitHub interface fact from memory, in a project
whose hard rule is that interface facts are looked up live.**

The suite asserts *"a PULL URL binds too, and is flagged"*. What I verified is that the gate **flags**
it. Whether a closing keyword plus a `/pull/` URL binds anything, I never measured — I wrote it from
memory, put it in a test name, repeated it in the PR body, and it was approved on the strength of a
vacuity proof that tested the gate rather than the claim about GitHub.

Looking it up afterwards produced two facts neither the issue nor the review had:

**The URL form is UNDOCUMENTED.** Neither GitHub docs page on linking or on keywords describes a
URL-based closing syntax; both document exactly `#N` and `owner/repo#N`. Yet quince#700 demonstrably
closed quince#683 through one. **So the gate now guards behaviour GitHub does not document** — which
makes the fixture the only authority there is, and means the behaviour can change without notice. If
this gate ever starts over-firing on link-heavy bodies for no visible reason, that is the first
hypothesis.

**And closing keywords are only interpreted when the PR targets the DEFAULT BRANCH.** Every PR here
targets `main`, so nothing is wrong today, but the gate's advice reads as unconditional and is not.

**The behaviour stays; the wording goes.** Flagging a `/pull/` URL is the safe direction and costs one
reading. What is being corrected is the justification, because a test name that asserts an unverified
interface fact is exactly the shape this project keeps paying for — and it is *more* dangerous inside
a guard, where the assertion reads as established.

**One smaller thing, from over-applying my own gate within the hour.** I ran it over an **issue
comment** and it fired. That is outside its declared surfaces — its header names the PR body and the
commit messages, and keywords are interpreted in a PR *description* or a commit message, not in an
issue comment. The gate was right about the text and I was wrong about where to point it. The natural
habit after making a gate stricter is to sweep everything with it.

**Not established.** No sweep of past PRs for how many auto-closed through this form; quince#701 lists
that as open and it stays open. The label/URL disagreement — a link rendering one number and pointing
at another — is neither handled nor claimed, and GitHub's behaviour there remains unmeasured by
anyone.
