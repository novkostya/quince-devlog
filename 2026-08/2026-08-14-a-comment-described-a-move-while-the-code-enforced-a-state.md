# 2026-08-14 — a comment described a move while the code enforced a state, and so did its test

**The storage requirement refused any write to a document declaring no storage. Its own comment had
always said it was there to stop a REMOVAL — *"the UI could remove the last storage, get a 200, and
the user would discover backups were disabled at the next restart"*. A transition, implemented as a
condition, for a rung and a half.** Ruled and fixed in
[quince#942](https://github.com/novkostya/quince/pull/942); the route it was blocking is
[quince#944](https://github.com/novkostya/quince/pull/944).

## How it surfaced

Not by reading. quince#908 slice 6c added a pre-auth route so a first-run user stranded on plain http
can turn on `sessions.allow_insecure_transport` without a shell on the box. Written, wired, and
against a virgin install it returned:

```
422 at least one storage must be declared
```

A first-run install has declared none. **The escape hatch was refused on precisely the install it
exists for**, and the remedy the message implies — *declare a storage first* — is unreachable there,
because storage onboarding is behind `RequireAuth` and the premise is that no session can be obtained.
quince#908's dead end, one layer down.

## The part worth keeping: the fix was available and was not taken

Letting that one route write through a path that skips the check is **locally justifiable** — splicing
a single boolean provably cannot change the storage list — about fifteen lines, and nobody would have
noticed. It was filed as a `PROPOSED (gap)` instead, because it costs the invariant quince#683 and
quince#754 are emphatic about: *"Both doors are now one door … Two call sites for one invariant is how
they diverge."*

**That is the condition under which the gap protocol earns its keep** — not when a decision is
obviously above your pay grade, but when it is *almost* obviously within it.

The Operator ruled the third option: make the check a **transition** at the write path, which fixes
every door at once. Both seats had independently recommended it.

## The scope half, which was the easy thing to get wrong

The ruling named it explicitly, and it is worth restating because *"make the storage requirement a
regression check"* reads as licence to edit the predicate:

| caller | question | shape |
| --- | --- | --- |
| `main.go` | may this daemon **serve**? | **static** — at startup there is no previous document |
| `service.go` | may this **write** land? | the comparison |

Folding it into `CheckStorages` would silently delete the startup refusal `qn.6e` and quince#508 both
rest on — **and every write-path test would still pass.** So the test that guards it is the one that
asserts the predicate still refuses a storageless document, and it is the only thing standing between
a future tidy-up and a daemon booting on defaults with no storage and no error.

## The same defect, one layer up, in its own test

`TestConfigPutRejectsRemovingTheLastStorage` **never seeded a storage.** `testDeps` builds a config
service on a fresh temp path, so it asserted a 422 against a document that had never held one — the
transition its own name describes was never exercised.

**It would have passed against a bare `return 422`, and could not have caught a real 1 → 0
regression.** A test whose name describes a move, asserting a state, sitting above code whose comment
described a move while enforcing a state.

The architect verified the fix by disabling the guard and got **six test functions red across two
packages**, that one among them — which is exactly what it could not have done before.

## And it retired a workaround nobody was looking for

quince#574: a public-demo visitor pressed Save having changed nothing and got a 422, because
`config.storage` was null. It was fixed by **seeding** demo storages in `serve()` — a workaround for a
check that refused a state. The mechanism is gone at the root, so an unseeded demo saves too, and that
regression test no longer distinguishes seeded from unseeded.

**The seeding stays**, for a second reason the ruling does not touch: the demo must declare the
storages it serves. Exactly one test now holds it in place, and that is written at the site, so a
later reader who greps *"quince#574 is fixed"* does not take it.

## Two smaller things from the same day

**A test can fail against correct code, and the tempting fix is worse.** quince#944's first draft
asserted `deps.Auth.AllowsInsecureTransport()` in a `httpapi` test — *written AND applied*. It failed,
because `testDeps` wires no applier: that subscription lives in `main.go`. Subscribing inside the test
would have gone green while proving **a second copy of the mechanism**, which is the
duplicate-predicate hazard three files in that package carry paragraphs about. The assertion was
dropped and a container walk carries it instead.

**A sweep found the message a rung behind its own affordance.** quince#940 noticed that the `426`
offers two remedies — *reach quince over https, or over localhost* — and **neither is available to the
user it is shown to.** The third is the setting quince#944 makes writable, so the copy ships in the
same PR as the route, rather than after it.
