# 2026-07-31 — I wrote down the reason, and still applied it out of scope

**`qn.6c` story 1 shipped a `PUT /api/config` that answered `200` to a config quince would refuse
to start on** (quince#394). The rule was enforced at startup and nowhere else, so the UI could
remove a user's last storage, report success, and the user would discover backups were disabled at
the next restart. Caught at review.

**The interesting part is not the miss. It is that I had written the reason down, correctly, in a
comment, and then applied it one caller too far.**

The design decision was to keep the storage requirement out of `Validate()`. That is right, and the
reason is specific:

> `Load()` **discards** a config that fails `Validate` and returns `Default()` with `OK:false` …
> expressing "no storages" as a validation error would produce a daemon running on defaults with no
> storage and no error.

True of `Load`. I then treated it as true of `Validate`'s **callers**, and `Replace` — the save path
— has the **opposite** property: it returns the errors and writes nothing. The hazard that
justifies the exclusion does not exist there. So the exclusion bought nothing on that path and cost
the `no silent caps or fallbacks` rule.

**A justification that names the mechanism it depends on is MORE dangerous than one that does
not**, and that is the reusable half. A bare assertion invites a reader to check it. A comment
citing `Load()`'s fallback behaviour reads as though the scope has already been worked out — by
someone who had the file open, no less — so neither I nor a reviewer skimming it asks *which
callers actually have that property*. It got past me twice: once writing it, once when I put the
same claim in the PR body as *"a PUT that omits `storages:` must be a 422"* — a sentence describing
behaviour I had not implemented, sitting directly above the code that did not implement it.

The fix is three lines in `Replace`. The pair of tests matters more: `Replace` must **refuse what
`Validate` permits**, asserted alongside the existing test that `Validate` permits it. Two tests
that only make sense together are the honest encoding of a boundary that was collapsed once.

---

**The same shape, mechanically, an hour earlier: a gate that reported green over nothing.**

I ran `make gates SCOPE=origin/main...HEAD` **before committing**. That range compares *committed*
history, so it was **empty**: the ladder ran `gates-sh` alone and exited 0. A green I had not
earned, produced by a command that was correct in every respect except the one that mattered.

**What caught it was an answer that looked wrong.** `bin/gate-scope --needed gates-ui` returned `3`
— *provably not needed* — when I had just edited `ui/src/lib/types.ts`. The tool was telling the
truth about a broken commit: a `git stash`/`pop`, run to inspect something else, had unstaged
everything, and `git commit` without `-a` took **4 files of 19**.

Both halves of this entry are the same failure: **a claim that carries its own justification and is
still out of scope.** The gate cited a range; the comment cited a mechanism. Neither was wrong about
what it named, and both were wrong about what they covered.

---

**Two things the code survey found that the spec had not, recorded because neither was reachable
from the spec.**

**`--demo` never builds the storage subsystem.** A refusal placed twenty lines earlier — before the
`if *demoMode` branch rather than inside its `else` — would have refused every demo and every
`ui-e2e` run over a subsystem they do not use. **Three call sites** (`Makefile` twice, `devct`) set
the retired variable and run `--demo`. Nothing in the spec would have caught it; the `e2e` gate is
what proved the placement rather than the argument for it.

**`unknownKeys` recursed only into struct fields.** A slice of structs was walked as far as the
slice and no further, so a typo *inside* a storages entry — `pathh:` — was dropped by
`yaml.Unmarshal` and reported by nothing. A mistyped path would have read as an **omitted** one,
and the storage would land somewhere the user never named. This rung was about to add the first
slice-of-structs to `config.yml`, so a D12 typo-guard hole would have opened at exactly the moment
the guard mattered most.

Both were found by reading the call graph before writing, not by tests. **Neither is the kind of
thing a spec review catches**, which is an argument for the survey step rather than against the
spec.
