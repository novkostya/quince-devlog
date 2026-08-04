# 2026-08-04 — the rule was already in the repo, three times, and the bug was that nobody had propagated it

**Eleven UI changes landed in one session and the same shape produced four of them: a rule this
codebase had already learned, written down with its reasoning, applied at one site and not at its
siblings.** Not a knowledge gap — a propagation gap, and the two are fixed by different things.

The four:

- **quince#631** — Settings scrolled sideways on a phone because a grid column had no `min-w-0`.
  `AppLayout` installs exactly that guard on `<main>` and *states the intent in a comment*; the chain
  broke one level below it. `JobLogPane` already had the wrapping half, with this precise bug named
  in its own comment from the `qn.6a` mobile pass.
- **quince#616** — form fields were 14px, so iOS zoomed. The ruling said *extract a shared `Select`*;
  a shared component with two copies of the responsive string would have satisfied the ruling and
  rebuilt the bug. The fix was to share the **string**.
- **quince#647** — an untouched device page selected the never-created storage, because `""` is both
  "nothing chosen" and that storage's real id. `versionsOn`, one file away, guards the identical
  hazard and writes out the identical reasoning.
- **quince#512** — card buttons did not align, and the file asserted twice that they did.

In every case the fix was to give the rule **one home** rather than a fourth copy. That is the
lesson, and it is not "write it down" — it was written down, well, with the reasoning intact.

## The correction that was worth more than the fix

**quince#628 blamed the wrong thing, and it said so in advance.** It attributed an unreachable
storage being pre-selected to the default-storage fallback, and carried this:

> *If the selected storage is **not** the declared default, the cause is elsewhere and this analysis
> is wrong.*

Checking took one read of staging's startup log: the declared default is reachable. The fallback
never ran. The fix still landed — it is a real latent defect — but as a *latent* one, and the
Operator confirmed after deploy that the symptom was still there. The actual cause was the empty-id
collision above, plus quince#627's unscoped diagnosis rendering a line about a storage the user was
not using.

**An issue that names the measurement which would falsify it is worth more than one that is right.**
This one was wrong and cheap to correct; a confident version would have closed with the symptom
still on screen.

## Two orderings, one real and one not

The triage said quince#630 and quince#624 *"touch different files, so they will not conflict and do
not need stacking"* — true of text, false of behaviour. Once the demo's second storage has a
history, quince#630's **old** G4 assertion fails. The branch was red until quince#630 merged. **File
paths do not establish independence**; only behaviour does.

The other pair, quince#627 → quince#628, was ordered for a better reason: the first leaves behind
the one sentence the second needs, so whichever landed second would find it already written. That
ordering was in the ruling and it held.

## Counts that agree because they are computed

**quince#624** was the largest: no demo version carried a `storage_id`, so anything per
`(device, storage)` found nothing and rendered the empty case *under a header asserting 14*. Three
surfaces, three answers, one fixture set.

Making the counts a fold over the versions found two more defects that reading had not:

- the growth trim scanned from the **end** of the version list, which is where seeded history is
  appended — so the demo ate its own fixture, one version per backup;
- the storage page counted **missing** versions while the header and `DeviceCard` excluded them, so a
  storage holding one dead version reported 19 against its own 18. Found by the new e2e that sums the
  per-device rows against the header — the assertion caught a live disagreement on its first run.

**The e2e count assertions had to stop being literals.** `toContainText("14 backups")` matched the
provider's own `14`: assertion and subject were the same fabrication, so neither could be wrong. They
now assert *agreement between surfaces*, which is what the issue was actually about.

## What a phone found that no gate can

Four defects reached the Operator's screen with every test green — the third day running that has
been true. Two of the eleven are **structurally** ungateable: quince#645's chevron is painted by the
browser from the system palette (nothing in any DOM to inspect) and quince#647 needs a storage quince
has never reached (the demo has none). Their hardware confirmation was recorded on the issues rather
than left in a session, because a fix whose only evidence is a chat transcript is one the next
session cannot cite.

quince#645 also looked like a mobile bug and was not: nothing declared `color-scheme`, so the browser
drew every internal it owns from the light palette. WebKit ignores `color` for a `<select>` arrow;
Blink and Gecko tint it with `currentColor` — so `text-fg` was accidentally covering for the missing
declaration everywhere except the one WebKit surface in regular use.

## The process notes

**Staging ran an integration build by Operator instruction** — `main` plus the approved-but-unmerged
branches, cherry-picked locally, with the full ladder run **on the combination**. That combination is
what no CI run covers: CI tests each PR against `main`, never the PRs against each other. The VERSION
was stamped `-pr646-648` rather than a bare sha, because a sha-shaped string that resolves to nothing
reads as corruption rather than as a deliberate non-main build.

**A ~40-minute stretch had no usable `Bash`** — the safety classifier was unavailable, fourteen
refusals, one trivial `echo` succeeding between them. Read-only tools kept working, which is what
allowed quince#649 to be diagnosed from the source while nothing could be filed. The session
reported the stop as *blocked and unwatched* rather than letting it look finished; the `Stop` hook
escalated to the Operator, which is what it is for.

Refs: quince#616, #631, #625, #630, #624, #627, #628, #512, #639, #645, #647, #649.
