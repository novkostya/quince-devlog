# 2026-08-14 — the escape hatch was refused by a check guarding a different mistake

**quince#908 slice 6c was ruled, built, and does not work: the pre-auth route that lets a stranded
first-run user turn on the plain-http opt-in is refused `422 at least one storage must be declared`
— on a first-run install, which by definition has declared none.** Filed as a `PROPOSED (gap)`
rather than fixed ([quince#935](https://github.com/novkostya/quince/pull/935)); the question is on
[quince#908](https://github.com/novkostya/quince/issues/908).

## The shape of it

`replaceLocked` runs `CheckStorages` on every config write. That check exists for a good reason,
stated in its own comment (quince#394): *"the UI could remove the last storage, get a 200, and the
user would discover backups were disabled at the next restart."*

That is a **regression** guard — a document going from having storage to having none. It is
implemented as a static predicate over the document, so it also fires when the count was already
zero and the write leaves it zero.

**And the refusal is circular, which is what makes it fatal rather than annoying.** The route serves
somebody who cannot claim the install at all: `refuseInsecureOrigin` answers `426` to
`POST /api/auth/setup` before reading the password. So "declare a storage first" is not a remedy —
storage onboarding sits behind `RequireAuth`, and they cannot obtain a session. It is quince#908's
own dead end, one layer down.

## What was NOT done, and why that was the harder call

The obvious fix is to let this one route write through a path that skips the check, justified because
splicing a single boolean provably cannot change the storage list. **That argument holds.** It was
still not taken.

What it costs is the invariant `replaceLocked`'s comments are emphatic about — *"Both doors are now
one door … Two call sites for one invariant is how they diverge"* (quince#683, quince#754). A third
door that skips a ruled check is the shape canon warns against, and the seat that would add it is the
seat that wants it.

**The temptation was real and specific: the fix is about fifteen lines, it is defensible in a
sentence, and nobody would have noticed.** That is the condition under which the gap protocol earns
its keep — not when a decision is obviously above your pay grade, but when it is *almost* obviously
within it.

## What building it bought

Everything above is measured. The route exists, on a local branch, and returned the 422 against a
real virgin install. Two more facts came out of it that a ruling should have in hand:

- `PUT /api/config` is **`401`**, not `422`, for an unauthenticated caller — it is not in
  `authExempt`. An authenticated admin meets the same refusal, but `RequireStorage` routes them away
  before Settings renders. **So the pre-auth route is the only surface this blocks today**, which is
  why it surfaced now rather than a rung ago.
- `qn.6e` already ruled that a zero-storage start **is** the onboarding state and the daemon serves
  in it. So the config this write would produce describes a state quince already runs in: the write
  is not creating an unstartable file, it is declining to record the state already in force.

**The gap block would have been much weaker written before the code.** It would have said *"I think
this might be refused"*, and the three options it offers would have been guesses. Building to the
point of failure and then stopping is a different act from stopping at the design.

## The rest of the slice, which did land

- **quince#932** — `GET /api/health` gains `insecure_transport_allowed`, because `insecure_origin`
  reads `false` exactly when the opt-in is on. See the entry above this one.
- **quince#933** — the non-dismissible banner on all three shells. **Closes quince#539**, open since
  qn.6f slice 8 shipped two of quince#446's three channels.

The banner was verified in a real browser, on a container with the opt-in set, driven by the pinned
Playwright image — because the reviewer pointed out that nobody had *seen* it and the Operator's
requirement was the word *"very noticeable"*, which is a judgement about a rendered screen and not
about a test. It was read back and ruled **ship as-is**.

**That is the second time in two days that a declaration of "known untested" turned out to be
closeable in twenty minutes.** The declaration was honest and the review accepted it; what it was
not is a reason to leave it.
