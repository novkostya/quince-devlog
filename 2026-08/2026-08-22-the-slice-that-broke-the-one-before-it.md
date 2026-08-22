# 2026-08-22 — Three defects, each created by the slice before it, none visible in its own review

**`qn.13` finished its remaining slices in one session: 7, 11, 8d, 8e, 8f — twelve PRs, all merged.
Three of them shipped a defect that existed ONLY because of the change immediately before, and not
one was visible in the review of the PR that caused it. Every one was found downstream, twice by the
Operator on a phone and once by probing a rendered DOM. That is the shape worth keeping; the slices
are just PR numbers.**

## The chain

**8d-2 made a scoped holder's Home their device page.** Correct, ruled, tested, approved. Two files
away, above *Share this device*, sat a comment reading *"a scoped holder never reaches this page's
own admin surface"* — **true when it was written** at slice 9, because a scoped holder then had no
route to a device page at all. 8d-2 falsified it without touching that file, and the section began
rendering to household members, offering them the means to invite another one. The API refused
throughout; nothing leaked. The Operator found it in a screenshot.

**8f-1 projected the storage list to `{id, name, reachable}`.** Correct, ruled, tested, approved. It
removed `default` — which is the admin's operational picture and should not be sent. `chosenStorage`
falls back to `default`, so it resolved to nothing, `value` stayed `""`, and **the browser selected
the first option anyway.** The select displayed one disk while the request would have named none,
sending the backup to the admin's default. Found by rendering the component with a projected list and
printing what the select actually held:

```
PROBE: select.value="st-1" displayed="attic disk"
```

**8f-1 also made `Storage.path/backend/default` optional**, which was honest — and left seven other
fields the projection omits still declared required, so the type described a payload no scoped holder
receives. Found by trying to make it honest and watching `tsc`.

## What they have in common, which is not carelessness

Each PR was correct **against its own claim**. Each was reviewed carefully by a seat that mutation-
tested it. The defect in every case lived in **a premise held somewhere else** — a comment in another
file, a fallback in another function, a type shared with four other surfaces — and a reviewer reading
the diff cannot see a premise the diff does not contain.

The generalisation the rung earned: **a slice that changes who can reach a screen invalidates every
claim about who can reach it, wherever those claims live.** Grepping for the routing change finds the
router; it does not find the sentence in a component that was true because of the old routing.

## The other thread: three vacuous greens in one day

Separately and more embarrassingly, three tests passed while proving nothing.

- **quince#1452**: three absence assertions passed with the filter under test **deleted**. They awaited
  the fetch being *issued*, not resolving, so they asserted emptiness about a component that had not
  rendered.
- **quince#1465**: a test written for the revoked-credential branch passed for the wrong reason — the
  fixture removed the only credential, so the install went unconfigured, the read returned
  `needs_setup`, and the branch under test was never reached. The assertion was `!= authenticated`,
  which `needs_setup` satisfies.
- **quince#1467**: `RequireAdmin` was proven to redirect and never proven to be **attached**. Dropping
  it from a route left all 924 tests green.

**All three were found by mutating the code, none by reading the test.** And the architect hit the
same wall twice: the obvious way to disable a Go condition leaves a variable unused, the package does
not compile, and *a build failure proves nothing about a test*. It cost three people a run across two
repositories in one day.

## A near-miss worth more than the defects

A test fixture in quince#1473 carried a device name **copied from the Operator's photograph of the
real stand** — a household member's given name. Caught in review, amended before merge, so it never
reached history.

**The privacy gate was clean before the amend and clean after**, because that name was in no pattern
list. The gate answers *"is this a string somebody already recorded as private"*; it cannot answer
*"is this a real person"*. What established the fix was `git grep`, not the sweep — and quoting a
clean sweep as evidence would have been a proxy for a question it does not answer.

The name is now in the private list, behind a leading-boundary pattern rather than a bare substring:
the given name is inside `catalina`, which this project could legitimately mention.

**The general lesson is about the input, not the gate.** Screenshots are the highest-risk thing that
enters this loop: one was read and its contents were in a commit within the hour.

## Ruled this session

- **The storage row SPLITS** (Operator, in session; architect on quince#1472). A scoped holder reads
  the list to choose a destination; storage management stays the admin's. Transcribed into the spec
  as D3's second exception, because an in-session ruling is binding and uncitable.
- **The architect declined to act on an implementer's relay** of an Operator quote, and confirmed it
  first-hand instead — quince-devlog#254's gap, met and handled.
- **A new scope class**, `scopedProjection`: every other scope-aware route filters rows by device,
  this one filters fields and has no device in it.

## State

Every slice of `qn.13` merged. The stand is one commit behind. **The end-to-end walk — the rung's
oldest debt — is still unrun**, and the Operator reached the device page but never completed the
sequence.
