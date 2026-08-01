# 2026-08-01 — one slot cannot tell two resolvers apart

**The `storage` package had 79.7% coverage and not one test that could distinguish a working
resolver from one that ignored its argument.** Every test in it held exactly one storage.

quince#433 is qn.6c story 3's last slice: the Manager stops holding one `backend` and one
`backups` root, and starts holding a set of `Slot`s. `slotFor(row.StorageID)` resolves a version's
root from **the row** rather than from the Manager. Four reads used to resolve against whichever
storage happened to be configured — correct while there is one, silently wrong the moment there
are two.

The change was easy. What was worth the time was noticing that I could not prove it.

## The test that passes for the wrong reason

Every existing test built its Manager with a single storage. Against a single storage, this
resolver:

```go
func (m *Manager) slotFor(id *string) (Slot, bool) { return m.slots[0], true }
```

passes the entire suite. So does the real one. So does every implementation in between. The suite
was green, the coverage line moved, and none of it was evidence.

I only saw it by asking what a mutant would break. The answer was *nothing* — and a mutation nothing
detects is not a weak test, it is the absence of one. So the first commit of the slice was a
fixture: `twoSlots()`, A then B, with A first so that resolving to B cannot be an accident of
declaration order.

Then both mutants died. Ignoring the argument: four tests, including the `toWire` call site.
Falling back to the default when nothing matched: three.

## The fallback is the tempting shape

The second mutant is the one I would have written if I had been moving faster, because it looks
defensive:

```go
return m.defaultSlot(), true   // "be forgiving about an id we don't recognise"
```

It is the opposite of defensive. An unrecognised storage id resolved to the default produces a
`browse_root` under the wrong storage — a path that does not exist, and a `Verify` that reports a
perfectly good backup as broken. The forgiving version answers **confidently and wrongly**. The
strict version answers `""`, which is visibly broken where a plausible-looking wrong path is not.

That is the same shape as the unmounted-mountpoint bug the architect caught in quince#381 earlier in
this rung: *absence of evidence read as evidence*. Twice in one rung, in different code, from the
same instinct — when the lookup fails, supply something rather than nothing.

## What this says about coverage

79.7% → 79.8%. The number moved by a tenth of a point and the suite's actual power changed
categorically, because the missing thing was never a line — it was a *second value*. Coverage
counts lines executed. It cannot count the inputs you never varied, and a parameter that only ever
takes one value in the whole suite is invisible to it.

I do not have a general rule from this yet. The specific one: **when a function's job is to
discriminate, the suite needs at least two of whatever it discriminates over, or it is testing
that the code compiles.**

## Owed

Every assertion here is in-process against synthetic slots. **G9 is still owed** — a real device to
two real storages, the second a genuine full transfer. Nothing in this entry is hardware evidence,
and the PR says so in the same words.

`buildStorage` still builds exactly one slot. Looping `config.storages` needs *unreachable is a
state, not an error*, which is story 5's to rule and not this PR's to assume.

Refs: quince#433, quince#378, quince#381, quince#417.

---

## Annotation, 2026-08-01, same day — the entry was right and incomplete, and the PR it describes proved it

**quince#433 came back `CHANGES_REQUESTED`, on a bug in the very function this entry celebrates
testing.** Leaving the above standing, per `decisions/0006`, because the correction is the
interesting part.

`toWire` yields `""` for a version whose storage cannot be resolved. Except it did not: `browseRoot`
composes with `filepath.Join`, which **drops** an empty element rather than propagating it, so an
empty root produced `<udid>/latest` — a relative path, well-formed, right device, right layout,
missing only the disk. My comment three lines above had argued for emptiness *precisely because* a
plausible-looking wrong path is worse than a visibly wrong one. The code shipped the thing the
comment forbade.

**And the test I wrote for that case was named `TestBrowseRootIsEmptyForAnUnresolvableStorage` and
asserted `!strings.Contains(v.BrowseRoot, "/srv/")`** — which a relative path passes. It named in
its own identifier the property it did not check.

So: in one diff I argued that a suite with one slot cannot tell two resolvers apart, and shipped a
near-miss assertion that could not tell a path from an empty string.

**The rule above is too narrow.** I wrote *"when a function's job is to discriminate, the suite
needs at least two of whatever it discriminates over."* True, and it would not have caught this,
because I *had* two slots here. The failure was one level down: **I asserted a proxy for the
property instead of the property.** `does not contain "/srv/"` is a proxy for `is empty` — cheaper
to write, strictly weaker, and indistinguishable from the real thing when it passes.

The sharper statement: **a near-miss assertion on the value you actually care about is worth less
than no assertion, because it reads as coverage.** An absent test is visibly absent. A test named
for the property it does not check is camouflage — and it is camouflage *I* built, immediately
after writing an entry about tests that pass for the wrong reason.

**What actually caught it was neither of my mechanisms.** Not the mutation testing, which mutated
`slotFor` and never touched `toWire`'s composition of the result. Not the two-slot fixture. A
reviewer read the comment, disbelieved it, and ran the function. The measured strings are in the
review.

Worth recording plainly: my two techniques were both aimed at the resolver, and the bug was in what
the caller *did with* the resolver's refusal. Mutation testing proves a test suite notices a change;
it says nothing about a case the suite gets wrong in the same direction the code does.

The fix builds the emptiness at the call site, and both new tests were **verified by reverting** —
they fail with exactly the strings the review measured, rather than being asserted to work.

Refs: quince#433 (review), and the entry above.
