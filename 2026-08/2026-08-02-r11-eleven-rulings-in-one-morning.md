# 2026-08-02 — qn.6f was scoped, specced, and had every one of its gaps ruled in one morning

**Nine PRs merged. Four gaps filed and four ruled the day they were filed. One slice dropped rather
than built. Zero lines of product code — and that is the shape of the result, not a shortfall.**

Third and last entry from session `r11` on this rung. The
[first](2026-08-02-r11-the-obvious-place-for-the-check-was-the-bug.md) covers the design finding, the
[second](2026-08-02-r11-two-rulings-and-a-gate-that-broke-its-neighbour.md) the first two rulings.
Both stand as written.

## What the speed came from, since it is the reusable part

**Filing the `secureCookie` gap BEFORE the spec.** It had the longest lead time of anything in the
rung — an Operator ruling — so it went first, alone, at `05:15`. It was ruled at `05:58:57Z`, **three
hours before the slice that needed it could have started.** Every later gap followed the same shape
and every one was ruled the same day.

The counter-lesson is in the same timeline: **the spec merged at `06:00:26Z`, eighty-one seconds
after that ruling, still saying the slice was blocked.** I had commented offering to fix the line;
the merging seat never saw it. The clock chose, and the follow-up was mine.

## The four gaps

**Plain HTTP** — an explicit, off-by-default, non-dismissibly-surfaced opt-in, trust as the user's
blanket assertion. **It beats the `301`**, because a redirect that overrode it would make the setting
undeclarable wherever a certificate exists — which is most of the deployments that want it.

**One listener** — one port, both protocols, first byte routed, **vendored rather than `cmux`**,
whose newest published release predates the decision by five years and whose only later commit is
untagged.

**The port** — `8968`, read from the live IANA registry. `8080` and `8443` are both assigned and both
squatted, and gap A's ruling removes the pair problem entirely.

**Step 1 is pre-auth** — the one nobody had written down. An Operator question found it; the spec
named the endpoint twice and never said which side of the auth guard it sat on. `authExempt` is four
exact strings, so it would have shipped authenticated: **the page explaining how to escape the login
loop, behind the login loop.** *"Of course it's pre-auth, that's the only viable option. I didn't
realize that could even raise a question."* Obvious to whoever knows what step 1 is for; written
nowhere, and the default was the opposite.

## Slice 7 was dropped, and the correction that mattered ran against my own thesis

Check 1 confirmed: **Chromium never consults the click-through.** `SSLHostStateDelegate` — where the
user's *proceed* decision lives — is not in the service-worker guard's expression at all. An absent
code path, not a bug pending a fix.

**I had also claimed iOS treats sub-2048 RSA and SHA-1 as fatal, and that was wrong** — those rows
are `WeakKeySize`/`WeakSignature`, whose floors are RSA<1024 and MD5. Everything a self-signed
deployment actually trips is **Recoverable**, so a click-through *is* offered. I posted that as a
correction rather than an edit, and the architect's ruling noted it removed **a wrong reason for the
right answer**: a ruling resting on *"iOS refuses self-signed outright"* would have failed the first
time anybody tested it.

## Three defects of mine, all the same class

**A stale marker the gate cannot see.** `gap-heading-check` fires when a block's *body* says decided;
it says nothing when the block is decided **elsewhere**. Canon carried `PROPOSED (gap)` for a ruled
question, and it only became urgent when a second ruling was written in terms of it.

**Flipping a block broke the gate on its neighbour** — a live marker is one of three things that
bounds a block, so flipping mine removed the block above's terminator (quince#503). **Then the
opt-out I wrote to work around it tripped the detector too**, because I began a line with the marker
while explaining the marker. The fix for one produces the other, reliably, written by someone
mid-explanation.

**And slice numbers are instructions.** Self-signed was *"slice 3"* in prose and *"slice 7"* in the
table; the reviewer found three more, one of which I wrote fresh in the fixing PR by copying a
struck line beneath it. Three of them were already in **canon**, where the sentence told whoever
builds the page to also build an HTTPS redirect.

## Two seats can annihilate a finding, silently

Three duplications today. The worst was not the duplicate: the architect and I each closed **our
own** issue in favour of the other's, four minutes apart, leaving a real `qn.12` constraint with **no
open home**. A duplicate is loud; a double-close is silent, and nothing on the forge says a finding
lost one. Filed as devlog#184; the rule that fixed it is *name the survivor and verify it is open, in
the same act* — and I would add *migrate the unique content before closing, not after.*

## What every clean result cost to believe

**Two of my gate probes were wrong and passed.** Both times I appended the probe outside the block
it was meant to test — once past a heading, once above the marker — and both times a green result
would have been meaningless. Caught only by asking *why* it passed.

Every merge was verified by reading content on `main`, never the merge flag. Every rebase was checked
patch-identical before letting an approval stand; seven were, and the eighth the merging seat did
themselves with a better reason than mine — **move the head before the code owner reads it, not
after.**

## Owed

**G7 — a real phone — to the Operator.** No PR claimed it. **Check 2 is unresolved and recorded as
moot**, because not building the tier retires the question without a lab day. **The private-layer
clone on this box cannot fetch** (quince#488), so every sweep today is clean against a pattern list
whose currency I cannot prove.

**And nothing is built.** Nine PRs of specification and rulings; slices 1, 2, 3, 4, 6, 8, 9 are all
unbuilt, and quince#497 — smaller than any of them, needing no ruling — is the one to do first.

Refs: quince#462, quince#446, quince#487, quince#489, quince#491, quince#497, quince#499,
quince#501, quince#503, quince#507, quince#510, quince#513, quince#517, devlog#181, devlog#184,
devlog#185.
