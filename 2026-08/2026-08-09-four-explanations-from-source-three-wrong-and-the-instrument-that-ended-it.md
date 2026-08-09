# 2026-08-09 — four explanations produced from source, three of them wrong, and the instrument that ended it

**quince#762 cost four mechanisms read out of the source before anyone measured anything on the
device. Three were wrong, one of them mine twice over, and the fix that finally shipped was found by
building a readout and looking at it.** The pattern is worth more than the diff: every wrong answer
was a plausible reading of real evidence, checked against a browser that has no keyboard and no
notch.

**The bug.** Every dialog in the product sat against the top of an iPhone screen with its head under
the Dynamic Island. Filed with three candidate defects, all inferred from `dialog.tsx`.

**The four explanations, in order.**

1. **Overflow** — a dialog taller than the viewport has its top pushed off. Withdrawn by the analyst
   when a screenshot showed a *short* dialog at the top with a screenful of page below it.
2. **"Mechanism unknown"** — the issue then recorded the position as unexplained and asked for
   devtools on the device. It was not unknown: `top-4 sm:top-1/2` had been added deliberately two
   days earlier (`e4dc144`) to keep the keyboard off dialog inputs. The analysis was made against a
   clone predating that commit, which is also why it claimed no test opened a dialog at a phone
   viewport — `story5` had since `63c2a36`. The architect caught the stale clone from the tell the
   issue itself printed: `git log` returning one commit for a file in a UI that had had a mobile pass.
3. **`window.innerHeight` shrinks with the keyboard** — mine. I clamped the visual-viewport offset
   against `innerHeight - height` and, when the dialog misbehaved, concluded that difference collapses
   to zero on iOS. **Measured later with a readout: it does not shrink, in Safari OR in the standalone
   PWA** (714/377 and 812/471). Both formulas agree on every reading anyone has taken, so the commit
   credited with fixing the gross mispositioning changed no number. Something did improve; what, is
   still unknown, and the code now says so instead of claiming it.
4. **A one-frame "keyboard closed" transient** — also mine, inferred from a taller card with a
   scrollbar in a screen recording. The Operator: *"Scroll bar appears only when I scroll. While
   jumping there's no scroll bar."* Those frames were a manual scroll. The 250ms settle I built on
   that reading was not merely useless — it was visible, because tapping `Check` dismisses the keyboard
   and grows the form in one gesture, so the dialog sat squeezed into the old keyboard-sized box with
   its text clipped for a quarter second. Reverted.

**What ended it was an instrument, not a fifth theory.** A `?vvdebug` readout of what iOS actually
reports — viewport height and offset, `innerHeight`, `clientHeight`, `scrollY`, the published custom
properties, the dialog's own box — plus a rolling log of the last events with timings, so one
screenshot after a jump carries the sequence that produced it. It falsified two committed claims
within one run and confirmed the geometry directly: `card y=62` against `safe top=62`.

**IT ALSO COULD NOT BE PERFORMED, TWICE OVER, AND THAT IS THE SAME DEFECT ONE LEVEL UP.** The URL
flag is useless in a home-screen PWA — no address bar, and `start_url` is `/`, so iOS drops the query
string. The gesture I added instead watched the top-left 64px, which on an iPhone belongs to iOS
("tap to scroll to top"), and its handler touched `localStorage` unwrapped where the boot path was
already in a `try`. The readout itself was drawn at `top: 0`, i.e. behind the Dynamic Island —
readable in Safari, where it was written, and not where it was needed. **An instrument built in one
context, verified in that context, broken in the one that matters** is precisely the bug it existed
to diagnose.

**A fix that did nothing nearly shipped.** quince#649's gap turned out to be reproducible from this
work, and a reset was written for it. The same readout showed `scrollY` is 0 throughout while
`offsetTop` runs to 153 — different quantities, so `scrollTo(0, 0)` had nothing to undo. Removed
rather than left labelled: a fix that does nothing is worse than an open issue, because it closes the
question in the reader's mind. quince#649 keeps a better-supported mechanism and no remedy.

**The gate caught one thing no human would have.** Scrolling a dialog inside `focusin` moves a button
out from under the pointer between `mousedown` and `mouseup`, so the browser fires no `click` at all.
`gates-ui-e2e` failed deterministically — attempt and retry — with a pressed button whose handler
never ran. It would have swallowed real taps on a phone exactly as it swallowed the gate's. The
correction now runs only for things that can raise a keyboard.

**Six negative controls, because a green test that has never failed proves nothing.** Every
behavioural change here was shown to go red with the fix removed, and the numbers were the
confirmation: `18` where the bottom inset was reserved twice, which is 34 − 16 exactly; `-30` for the
unwanted scroll step; `top: '0px'` where `'200px'` was required. One e2e assertion **passes with its
fix unwired** — Chromium already clears that margin at the suite's sizes — and it says so in its own
comment rather than being counted as coverage.

**What shipped and what did not.** Dialogs clear the notch and the home indicator, centre in the
visible area, keep the focused field off the scroll region's edges, and stop reserving the home
indicator while the keyboard covers it. The residual jump on switching fields is **not fixed and is
not claimed to be**: a focus change is followed 60–90ms later by a `scroll` moving `offsetTop`, and
Safari paints that before reporting it, so compensation can never be earlier than its cause.
`interactive-widget=resizes-content` would remove the class at platform level and Safari does not
implement it. The Operator accepted the result as better than `main`, not perfect — which is the
honest state and is written into the pull request as such.

Nine deploys to the staging stand, each verified by the artifact rather than assumed. quince#791.
