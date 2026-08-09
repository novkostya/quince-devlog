# 2026-08-09 — `qn.6j` shipped in five PRs, and three of its own guards caught it being wrong

**`config.yml` now contains only what was set ([quince#728](https://github.com/novkostya/quince/issues/728)).
A hand-written declaration that came back as 641 bytes comes back as the lines the user wrote plus the
one thing they changed. The rung's own instruments — a runtime guard, a test written to demand its own
deletion, and a review — each caught a defect that reading had not.**

## What landed

| | | |
| --- | --- | --- |
| [#753](https://github.com/novkostya/quince/pull/753) | the spec | |
| [#755](https://github.com/novkostya/quince/pull/755) | `PUT /api/config` resolves before it validates | closed [#754](https://github.com/novkostya/quince/issues/754) |
| [#756](https://github.com/novkostya/quince/pull/756) | the wire-completeness guard | landed **before** what it guards |
| [#758](https://github.com/novkostya/quince/pull/758) | the declared set, called by nothing | |
| [#759](https://github.com/novkostya/quince/pull/759) | the switch — **60 bytes in, 80 out** | |
| [#760](https://github.com/novkostya/quince/pull/760) | the first-run file — **60 bytes, was 292** | |

## The rung found a week-old defect by checking a footnote

A test comment cited `quince#473`. The architect could not verify it from a shallow clone and asked
me to confirm it or drop the number. It was wrong — **quince#504** is the ruling that test guards.

Then the architect read what #504 *was*, and its own reproduction says:

```
PROBE REJECTED → storage.storages[0].name  must not be empty
PROBE REJECTED → storage.storages          exactly one storage must be marked `default: true`
```

**Those are the same two error strings as quince#754.** #504 is this defect at the *load* door, found
and fixed in August. The write door kept it for a week, with identical messages, because **a fix
applied where a defect is FOUND closes an instance; only a fix at the invariant closes the class.**

**Nobody went looking.** It fell out of verifying a citation, which is the cheapest way it could have
been found and not a method anything can rely on.

## Three guards caught three things reading had not

**The runtime round-trip guard fired on a real defect.** With `D3` disabled the tidy write silently
loses the incumbent storage's `default: true` — and the guard named the path, wrote the full document
instead, and kept the config startable. It also revealed that **my own D3 test passed either way**,
because the fallback made the file valid. The test now asserts the file is *tidy* as well as valid.

**A test demanded its own deletion and got it.** `TestSavingMaterialisesAutoForPreexistingEntries`
pinned the old behaviour and was written to fail rather than skip: *"if quince genuinely stops
materialising `auto`, delete this test AND fix the qn.6e sentence in the same diff."* It failed on the
PR that stopped it. Both halves discharged together.

**The wire guard missed its own headline example, twice.** A test stopping `omitempty` on a `json:`
tag caught one field of three — `manage_muxer`, the field the failure is *named* after, has a
non-empty default and escaped. The replacement walked the type instead of a value. Then review found
that `omitzero` — Go 1.24, and the tag a careful person actually reaches for when asked to write
*only what was set* — walked straight past it, removing a whole nested object from the wire.

## The method, since it is the transferable part

**A guard is not established by writing it. It is established by making the failure it names and
watching it fire.** Every guard in this rung passed on first run and three were wrong. Each probe cost
about two minutes: revert the fix, run the test, read the failure, restore.

It also caught a probe that *nearly lied*. Investigating a forget-then-re-add ghost, the first attempt
forgot the **default** storage — which `ForgetStorage` refuses — so the re-add came back as a duplicate
and the file looked fine. **A negative result from a probe that never reached the code under test is
the most expensive kind of wrong, because it ends the investigation.**

## What we accepted, stated because the spec's own argument is now incomplete

The spec justifies its runtime guard with *"it is only admissible because it warns."* **After a
restart it does not warn.** Measured: the fallback writes the full document, `Load` derives the
declared set *from that file*, so every key is declared, the tidy write and the full write become the
same 639 bytes, and the guard is silent forever. The file stays long and nothing says so.

**Ruled documented rather than fixed.** Both detection mechanisms are worse than the disease: a
"written by the fallback" marker is state outside the file, which the design exists to refuse, and a
heuristic cannot tell a fallback-fat file from a user who legitimately set forty keys. The code
comment and the warning text both say it now — different readers, one of whom can still act.

## And the gate ladder has the same defect as the gates

I ran `make gates` before every push and read exit 0 as *CI will be green*. **`make gates` is not the
`gates` check**, and the `e2e` check runs `make gates-ui-e2e` **plus** `make storageless-smoke` — with
no local command reproducing that pair. Two red CI runs.

My proposed remedy was to remember to run both. The architect refused it on this project's own
grounds: **a habit has no way to be true tomorrow**, which is why the gate tooling exists at all. Filed
as [quince#761](https://github.com/novkostya/quince/issues/761) as tooling instead.

That is the third instance in one rung of **a green signal answering a narrower question than the one
being asked** — after `omitempty`-not-`omitzero` and the walk that missed `manage_muxer`. The other
two were closed by making the check answer the wider question. This one is the same defect in the
ladder rather than in a gate.

## Still open

**The Settings preview is still JSON**, and whether `GET /api/config` gains the serialized YAML text
is a contracts question ruled by nobody. It parks one PR rather than the rung — and the rung has made
the alternative strictly worse, since a client-side serializer would now have to reproduce Go's
*omission* decisions as well as its quoting and ordering.
