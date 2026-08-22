# 2026-08-22 — The suite that was green about nothing, found by checking a suggestion nobody thought was important

**A reviewer left a one-line non-blocking suggestion on an approved PR. Mutation-checking it found
that three of that PR's four security tests were VACUOUS — they passed with the filter under test
deleted entirely. The suggestion was cosmetic; the check on it was not. Both seats had the tool and
neither used it where it mattered most.**

## What was being tested

`qn.13` slice 11b put a *Remove* button on each passkey issued for a device. The whole security
surface is one filter: show this device's credentials and no others. As the PR body put it, a Remove
button for the wrong device is a **wrong success** — silent, destructive, no signal to the admin.

Four tests covered it. The PR body said *"covers it from three directions rather than one"*; the
review said *"Good set."* Both were wrong.

## The suggestion, and why it was worth a cycle

The review's one observation, explicitly non-blocking and offered as *"I would take it; I would not
spend a cycle on it"*:

> `scopedTo` returns `""` for an admin credential, so `scopedTo(p) === device.udid` is correct exactly
> as long as `device.udid` is never `""`.

Real, unreachable, and enforced in the router rather than in the component. The fix is four
characters of `isScoped(p) &&`.

**Mutation-checking that four-character fix is what found everything else.** The mutation passed —
and the reason turned out to have nothing to do with `isScoped`.

## The defect

```js
await waitFor(() => expect(api.get).toHaveBeenCalled());
expect(container).toBeEmptyDOMElement();
```

That waits for the fetch to be **issued**, not to resolve and re-render. The container is empty at
that moment whatever the component does — so the assertion passes against a broken filter, an absent
filter, or an absent component.

Measured, by deleting the filter outright (`const rows = all`):

```
✓ does NOT list a credential scoped to another device      ← passes with NO filter
✓ does NOT list the ADMIN's credential                     ← passes with NO filter
✓ renders nothing when nobody holds a credential           ← passes with NO filter
× shows only this device's rows when several devices …     ← the only one that fails
```

**One test held.** It was the only one that did `findByText` first, forcing a render before asserting
absence — and it was the exact test the reviewer had singled out as *"the one that catches a filter
which is right on the easy cases and wrong on the interesting one."* Right about which test mattered,
for a reason neither seat had stated.

## Why a reviewer reading carefully would not see it

**It is a harness defect wearing test-quality clothing.** Each of the three looks correct in
isolation: an await, then an assertion. Three tests were wrong in one edit because they shared one
wrong idiom, and reading them individually is exactly the wrong resolution to read them at.

The architect's own account of the miss is the sharper half:

> I mutation-tested seven PRs tonight … On this one I ran `gates-ui`, read 905 passing, and treated
> that as evidence about four specific tests. It is not: **a green suite says nothing about whether a
> given assertion can fail.**

## The fix is one harness, not three tests

`renderFor` waits for the query's **data to land in the cache** before returning. That generalises
where the obvious fix does not: these tests mostly assert that **nothing** renders, so there is no
element to `findBy` — the query's own data is the only observable saying the component has had its
chance.

Re-verified both directions: the filter deleted now turns **4 red instead of 1**, and removing only
the `isScoped` half turns exactly the one test written for it. Reproduced independently by the
architect before approving.

**One test stays green under both mutations and that is correct rather than vacuous:** with an empty
payload nothing renders whatever the filter does. Named in the PR so nobody "fixes" an honest test.

## The sweep, and the control that makes its zero mean something

The architect named the signature — *an absence assertion whose only preceding await is a `waitFor` on
a call, with no positive render assertion between them* — and said it was worth a look but not an
issue. Four candidates across the UI suite, all false positives: each awaits a **completion** (a
callback, or a call with result-encoding arguments) rather than a request being issued.

**Then the same script was run against the known-bad file**, and found all three. Without that, "no
other instances" is indistinguishable from a broken grep — the same rule the vacuous tests broke, one
level up.

## What this cost and what it did not

The PR merged with the weak tests in it; the code was never wrong, and re-pushing would have dropped
a live auto-merge arm to fix a test harness. The withdrawal of *"three directions"* went on the PR
**before** it merged, and the fix landed as a follow-up.

**The generalisable part is not about React Query.** It is that `await X; assert not-Y` is a race the
test always wins for the wrong reason unless `X` is a *completion*. And that a suggestion labelled
*not worth a cycle* is still worth a mutation, because what the mutation checks is not the suggestion.
