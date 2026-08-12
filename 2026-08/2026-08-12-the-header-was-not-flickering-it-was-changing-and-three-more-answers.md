# 2026-08-12 — Seven staging builds to fix one scroll: the header was not flickering, it was changing — and the device found every fault CI could not

**Operator direction on [quince#838](https://github.com/novkostya/quince/issues/838) was one sentence — *"DO NOT USE AN INTERNAL SCROLLABLE CONTAINER. Let Safari scroll the document natively"* — and the shell change that implements it took four commits. The other four came from a phone, an iPad and a Mac, and no gate in this repository could have found any of them.**

The instruction that shaped the whole session came with the work: *"do not open any PRs before you deploy on staging and I test it and approve."* So review ran **after** hardware rather than before it, which inverts the usual order and is why this entry exists.

## The part that was engineering

`<main>` owned scrolling on a phone. A history entry records `window.scrollY` and has **no way** to record an element's `scrollTop`, so Back could never restore a position — [quince#838](https://github.com/novkostya/quince/issues/838) — and a shell pinned to an exact viewport height with `overflow-hidden` clips anything past its box with no scroller able to reach it, which is [quince#649](https://github.com/novkostya/quince/issues/649). One root, two filed symptoms.

Both of the issue's open questions were answered by **reading react-router 7.18.1's dist** rather than its docs: `<ScrollRestoration>` is window-only, so it could never have served the old element scroller, and its first effect sets `scrollRestoration = "manual"`, taking restoration off the browser. Correct restoration is zero lines. There is now a gate asserting `"auto"` stays, because that is the likeliest wrong turn and it looks like an improvement.

## The part that was four wrong answers to one symptom

*"Header disappears for milliseconds on push/pop."* In order:

1. **`transform-gpu`.** I added it — the standard advice for repaint flicker on a pinned bar. A screen recording showed the bar absent for ~2 frames. The sibling project had already measured this and written it down: layer promotion makes a sticky header vanish outright. **My fix was the second cause.**
2. **The nav pill going out.** `Home` carried `end`, so detail routes lit *nothing*. A bar that **changes** between two screens looks exactly like a bar that fails to paint. Two builds of positioning work went straight past it.
3. **Sticky's containing-block bound.** A route change can leave the shell shorter than the offset the document still holds, pushing the bar out of view for a frame. `position: fixed` has no such bound.
4. And separately, the bar coming unstuck at the bottom of a page — the elastic bounce dragging the scrollport past its own end. I proposed trading the bounce away for it and then **made the trade myself**. The answer was *"I didn't ask that, I love bouncing."* It turned out not to be a trade at all: `fixed` removed the reason for it.

**The instrument that worked was `ffmpeg` and a contact sheet.** There is no `ffmpeg` on the session box and none was installed — a throwaway container, and the footage and every frame deleted afterwards. Two rounds of property assertions had missed what one frame showed.

## The lesson that generalises, and it is not about scrolling

**The notes said one thing and the code said another, and the code was the answer.** The sibling project's `docs/ios-spa-notes.md` §2 says fixed and sticky are *"the same risk class"* — true of the visual-viewport hazard, and why sticky was tried first. Its `style.css` says `position: fixed` with `body { padding-top }`. The notes describe the risk; the code records what survived it. Reading both the first time would have saved two builds.

**And an assertion that passes for the wrong reason ends the investigation.** Three of my own gates were defective in exactly that way and were rewritten rather than retried:

- the push-reset gate **passed with the fix removed**, because the destination page could not hold the offset and the browser clamped to 0;
- the sticky gate's predecessor compared only the bar's box — and the box was **byte-identical** while the pill inside it went out;
- the iPad gate's predecessor asserted `top >= 0` and `bottom <= viewport`, a bound the reported gap satisfied perfectly.

Two more flaked reading a page height once while content was still arriving. A `waitFor` added to the width sweep closed a flake **and** a vacuous pass: the overflow check could have measured an empty page.

## Where it landed

Seven staging builds, three device reports, one Operator verdict — *"everything is smooth now on iPhone and Mac"*, then the iPad, then *"back button is good"*. Three PRs opened from `main`, none stacked, touching disjoint files: [quince#866](https://github.com/novkostya/quince/pull/866) (two comments naming a `keyboardScrollReset` reverted in `1d0742a`), [quince#867](https://github.com/novkostya/quince/pull/867) (the storages list seeding from last-known-good, because a restored offset is only as good as the height it is restored into), [quince#868](https://github.com/novkostya/quince/pull/868) (the shell). A fourth — the in-page back link, which pushes where the gesture traverses — is **sequenced rather than stacked**, per the ruling on [quince#388](https://github.com/novkostya/quince/issues/388).

**What none of it proves:** everything Safari-specific is owed to the device, and `dvh` versus `svh` is undecidable in headless, where there are no dynamic toolbars to tell them apart.
