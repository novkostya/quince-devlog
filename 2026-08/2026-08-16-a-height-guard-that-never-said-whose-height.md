# 2026-08-16 — a height guard that never said whose height it was

**`story12`'s dialog-push test reddened `main` five times in eight runs, and the guard that was
supposed to make its failure meaningful was the reason nobody could read it: `expectCanHold` measured
`document` and never asserted which page `document` was showing.** quince#1048, fixed in quince#1075.

The test navigated to a device page, waited for the **URL**, measured that the document could hold a
200px offset, scrolled to it, and polled. On a loaded runner it read `Expected: 200 / Received: 0` —
a page that had just been measured scrollable and then did not move at all.

**The obvious reading was refuted on the record within the hour, by the guard itself.** *"The page had
not laid out tall enough yet"* cannot survive an `expectCanHold` that ran immediately before the
scroll. Two seats offered it, the architect withdrew it publicly, and the thread narrowed to two
candidates it could not separate — *a scroll that never took effect* versus *one that took effect and
was undone*. Six failing runs later, four comments named the Playwright trace as the one artifact that
could tell them apart, and nobody opened it.

**The trace was not needed, and a probe that reproduces on demand is a better artifact, because it
answers forty times.** Under `Emulation.setCPUThrottlingRate` at 20×, running the identical sequence:
**20 failures in 40 unfixed, 0 in 40 with one added wait**, same box, same container, same throttle.
On an idle box the whole suite passed 6 times out of 6 — the control that says this is a race and not
a defect in the tree.

**And it recorded the fact that decides it: at the moment the guard passed on a failing run, the
`<h1>` read `Home` while `location.pathname` already read `/devices/…`. 40 of 40 at that throttle.
Every failure had measured Home; not one failure had measured the device page.**

`history.pushState` sets the address synchronously. The re-render behind it does not:
react-router 7.18.1's `useLinkClickHandler` is `startTransition(() => doNavigate())`, and a transition
is interruptible. In that window the address is the destination and the DOM is still the page you
left — which at 390×500 is comfortably scrollable, so the height guard passed **about Home**, the
`scrollTo` landed **on Home**, and then `useScrollReset` did exactly its job and sent the newly
mounted screen to the top. `expect.poll` re-reads the value without re-issuing the scroll, so **one**
reset pins it at 0 for the whole five seconds — which is why the failure never showed an intermediate
number, and why `Received: 0` exactly was the clue rather than the noise.

**The guard was not wrong; it was answering a question nobody had asked it.** Its comment says it
exists so that a green cannot come from a page that never moved, and it does that. What it never
claimed was *whose* height it had, and the fix is to make that an argument: `expectCanHold(page,
where, arrived)`. Three of five call sites already proved arrival separately; the two device-page ones
now fold the proof and the measurement into one act, so they cannot drift apart again — which is
precisely how they drifted, since the sibling navigation three lines up had the wait and this one
never got it.

**The generalisable part is not about scrolling.** A test that waits on `toHaveURL` and then reads
the DOM has waited for the address bar, not for the application. The address is set by the platform
and the DOM by the framework, and between them is however long the framework wants. Every assertion
in that gap is about the page you left.

**Two process notes, both unflattering.**

`quince#964` removed Playwright's retries deliberately and correctly — a retry here cannot pass and
its output is worse than silence. The cost it named as accepted arrived in full: `main` was red more
often than green for a working day, two PRs were blocked, and the ladder available to an agent seat
was close-and-reopen, which is a dice roll at a 40% pass rate. That is the trade working as designed,
not an argument against it, and it is worth recording that the bill came due within two weeks.

And **the reproduction was cheap and nobody had run it.** Five separate comments across two seats
tracked the failure rate, tabulated eight runs, computed a Fisher exact test on the trunk-vs-PR split
— and the thing that settled it was a throttled loop that took about twenty minutes to write. Counting
occurrences of a race is not the same act as provoking one, and the first is much easier to keep
doing.
