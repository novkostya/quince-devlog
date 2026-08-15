# 2026-08-15 — I deleted the fix, and the bug went with it

**A dialog on a phone had been fought over three times — quince#649, quince#762, quince#816 — with a
JavaScript viewport follower growing at each pass. The Operator's instinct was that two later
rulings had made the whole mechanism unnecessary. Deleting it was the fix, and what remained was
two CSS rules and a history entry.**

Three staging builds in one afternoon, each judged on a device before the next was written:
quince#1028 and quince#1029.

## What was there

quince#762 put a frame around every dialog that tracked `visualViewport` and published `--vv-top` /
`--vv-height` / `--vv-pad-bottom`, plus a `focusin` correction that nudged the focused field clear
of the card's edges. It existed because iOS does not shrink the layout viewport for the keyboard —
it pans the visual one — so a `position: fixed` surface centres against a height that counts the
strip now behind the keyboard.

quince#816 is what it cost. **The browser paints its own scroll before it reports it**, so every
correction lands one frame after the thing that caused it, and the dialog jumps on every focus
change. That issue's triage had it right and said so: the compensation was working as fast as the
platform permits, tuning it was a coin flip, and the real fix was a WebKit bug somebody else owns.

## The instinct, and why it was right

The Operator's reading was that **quince#838 and quince#846 had removed the two conditions the
compensation existed under**: the document scrolls again, so the browser can bring a covered field
into view itself, and the heavy surfaces became pages, so no dialog still needs a bounded card
measured against a keyboard. Delete the machinery and let Safari do it.

That is exactly what happened. `useVisualViewport`, `useScrollFocusIntoView`, `keyboard.ts` and the
three custom properties are gone, and the one-frame jump went with them — confirmed on an iPhone
and an iPad. **The safe-area padding stayed**, because it is a fact about portalling rather than
about keyboards: a Radix portal inherits none of `AppLayout`'s insets.

## What the device found that the reasoning had not

**In landscape the encryption dialog is taller than the screen.** With the card's own scroll region
removed there was no scroller anywhere, so its head sat above the top edge and its buttons below the
bottom one — both ends unreachable. Portrait had hidden it; four fields do not fit in ~390px however
short a dialog is the other way up.

The answer was `min-h-full` on a flex row inside a scrolling overlay: a short card is centred in
exactly one screen and nothing scrolls, a tall one grows the row and the overlay scrolls it.

**The gate written for that is not about CSS.** Radix wraps its content in `react-remove-scroll`,
which blocks scrolling everywhere except the element it is handed — and the new scroller is an
*ancestor* of that element. Whether it could scroll at all was a question about a third-party
library's internals, so it was measured rather than reasoned about.

## And then the last symptom named its own fix

The remaining defect was reported with three screenshots: open a dialog at the top of a device page,
let Safari scroll the document to clear the keyboard, close the dialog, and the page underneath
stays where Safari left it.

The Operator's read was quince#931 — **a dialog is a place you went** — and it is the right one for a
reason worth writing down: the document moving is *correct*, and what was missing is that leaving
the page was never recorded as going anywhere. `history.scrollRestoration` is `"auto"`, so a push
saves the offset and a pop restores it. Opening pushes, closing pops, and **nothing in quince
restores anything**.

**A query param rather than a path segment, and that is the finding.** `useScrollReset` sends a new
screen to the top and keys that on the *pathname*, stating in its own comment that a query-only
change is not a new screen. `/devices/{udid}/encryption` — the shape quince#931 proposes — would
scroll the page to the top on open: the defect class, reintroduced by its own fix. `?dialog=…`
leaves the pathname alone.

## What this cost, and what it did not

Three deploys, no revisions to anything already agreed, and every judgement made on hardware between
builds rather than argued from source. The pattern that made it cheap was the Operator's: **name the
instinct, deploy it, look at it.** quince#762 records four explanations of this dialog from source,
three of them wrong.

**What is still owed to a device by construction**: there is no on-screen keyboard in a headless
browser, so the e2e performs the scroll it cannot provoke, and the edge-swipe gesture is
`page.goBack()` rather than a finger. Both are stated in the pull requests rather than left for a
reviewer to notice.

## The shape of it

The first two rungs of this project's own rule — *when you reinvent something the platform gives
you, you break something that was supposed to just work* — were quince#838 and quince#908 §4. This
is the third, and it arrived as a deletion rather than as a feature. **The diff that fixed a
three-issue bug removed 5 files and added 2 CSS rules and one hook.**
