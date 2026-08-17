# 2026-08-17 — `qn.12` builds, and the gates that mattered were the ones proven to FAIL

**Four of the rung's slices landed in an afternoon. The parts worth recording are not the features:
they are three gates that were run backwards to check they bite, one review finding whose fix
uncovered the same defect one state over, and an approved PR that sat for eighty-six minutes because
auto-merge cannot rebase.**

Merged today after the spec ([the previous entry](2026-08-17-the-spec-that-checked-its-own-facts-against-the-wrong-tree.md)):
[quince#1139](https://github.com/novkostya/quince/pull/1139) the `notifications:` rename,
[quince#1140](https://github.com/novkostya/quince/pull/1140) RFC 8291/8292,
[quince#1142](https://github.com/novkostya/quince/pull/1142) the service worker and install step.
Open: the notifier, the due affordance, the subscription store.

## A gate you have not seen fail is a claim, not a gate

Three times today the useful step was breaking something on purpose.

**The service worker.** `webui.handlerFor` falls through to `index.html` for any path it cannot
`fs.Stat`, with `Content-Type: text/html`. So a build that dropped `sw.js` does not 404 — it serves
the SPA shell, registration dies with a MIME error naming neither cause, and **every existing test
still passes**. A gate was added to `gates-ui`; then `ui/public/sw.js` was moved aside and the build
run again. It still succeeded, and the gate refused. The file went back and it passed.

**The error-code totality.** Go cannot enumerate a constant block, so "the notifier routes every
error code" is normally a hand-written list that quietly stops describing reality. It became a chain:
`backup.AllErrorCodes()`, a test in *that* package scanning its own source, and a test in `notify`
asserting every listed code routes somewhere. An eleventh constant was added to check both links —
unlisted, `backup`'s test failed; listed but unrouted, `notify`'s did.

**The RFC vector, which failed without being asked to.** `rs` in the `aes128gcm` header is the record
**size parameter**, not the length of this record. The wrong reading produces a body byte-identical
to RFC 8291 §5's worked example **in every other octet** — same salt, same keyid, same ciphertext,
same tag. A round-trip test could not have caught it, because our own receiver would have framed on
the same wrong number. The vector caught it on the first run, which is the whole argument for the
spec's decision to own this code rather than take a dependency.

## The fix that found the same defect one state over

The reviewer blocked the install page: `pushSupport()` discriminated on *is it installed* where it
needed to discriminate on *what platform is this*. A non-iOS browser with no Push API was told to
install; installing flipped the predicate, and the same page then said quince cannot help. **A dead
end reached by following quince's own instruction** — worse than a button that does nothing, because
the user spent an action on it.

Their sharper observation is what chose the fix: the non-iOS branch of that card **was reachable only
when it was wrong**. It had no correct audience, so the answer was not to reword it.

Checking the fix turned up the same shape one state along: an *installed* iOS app with service
workers and no Push API would have inherited the Lockdown Mode copy — **but Lockdown Mode removes the
service worker too, so having one rules it out.** That case is an iOS below 16.4 and now says so.
Naming a cause quince can positively disprove is worse than naming none, and the rule was written in
this rung's own spec before being broken in an adjacent state.

## Two copies of one rule, and the copy that was right was the dead one

`installState` and `pushSupport` both encoded the install question. `installState` had the correct
platform check, was exported, and was **referenced by nothing** — its doc comment claimed the page
rendered from it, which was false. It was deleted rather than wired up. The PR is its own argument:
two copies drift, and the one nobody calls is the one that stays correct.

The same shape, benignly, in the other direction: adding a `useConfig` call inside `DeviceCard` broke
all eighteen of that component's tests with `No QueryClient set`. That was the honest signal rather
than a harness problem — a card rendered N times in a grid should not fetch — and the read moved up
to the list.

## Auto-merge cannot rebase, and `strict: true` means everything is always behind

[quince#1140](https://github.com/novkostya/quince/pull/1140) was approved at `15:30:50Z` with
auto-merge armed, and sat while four other PRs merged past it. `CLAUDE.md` §6 already says why —
*"auto-merge does not rebase, so one armed on a `BEHIND` branch waits forever under `strict: true`"* —
and the arm had simply happened when the branch was already behind. One `gh pr update-branch --rebase`
cleared it and auto-merge fired.

**The generalisation is the part worth keeping: the PR approved LONGEST is the one most likely to be
stranded**, because it has had the most chances to go behind. With several PRs in flight that is the
ordinary case, not an edge one.

## And the review caught something canon had been missing

Flagging quince-devlog#274's exposure — a frozen-contract change landing on an architect approval
alone — turned up that the second principal **already existed**: the Operator had approved the spec
PR as code owner, because it touched `docs/quince.design.md`, and that spec carries the fifth push
kind with its reasoning.

**Route a contract decision through a code-owned document, and the code-owner requirement supplies
the second principal automatically.** No new mechanism; §8's spec-first rule already points that way.
It does not cover a contract change whose spec touches only unowned paths — which is quince#1107's
shape — so it narrows the exposure rather than closing it.
