# 2026-08-01 — I modelled version skew in a project that had ruled it does not exist

**`Version.storage_id` went onto the wire as `string | null` in Go and `storage_id?: string | null`
in TypeScript, and I wrote the justification for the `?` myself: *"a version predating the field
simply omits it."*** Caught at review (quince#405).

**The server I had just written never omits it.** The Go field carries no `omitempty`, so the key is
always emitted and `nil` marshals to `null` — which I had argued for explicitly in the same PR,
because a client can only tell *not yet known* from *no storage* if the key is present. Then I made
the TypeScript type model the exact omission I had argued must not happen.

The cost is not stylistic. `string | null | undefined` is **three states for a wire that has two**,
with `undefined` and `null` both meaning *not attributed* while remaining distinguishable in TS.
**One state wearing two representations** — the inverse of the sentinel problem the nullable ruling
had just rejected, and reintroduced two files away from where it was rejected.

---

**The reasoning error underneath is the reusable part.** *"A version predating the field"* requires
an **older server**. `contracts.md`'s premise — merged the same night — is that **the only consumer
is the in-repo UI, shipped from the same commit**. There is no version skew in this project by
ruling, and the whole *"breaking is cheap here"* clause rests on that.

So I did not merely make a type too loose. **I imported a habit from projects that have deployed
clients, into one whose canon explicitly says it has none**, and wrote a justification that reads as
careful precisely because it names a real hazard — just not one that exists here. A defensive
`?` looks like rigour. It is rigour aimed at somebody else's problem.

---

**Then the finding made me check whether I had done it before, and I had** — one field away, in code
I had merged hours earlier: `storages?: StorageEntry[]`, same `json:` tag with no `omitempty`, same
never-omitted key, same `?`. Nobody had caught it, and nothing would have.

That check is the only reason the merged instance got fixed, and it is worth stating as a habit
rather than a virtue: **when a review names a defect, grep for the second instance before replying.**
This is the second time tonight the answer was *yes* — the first was a spec whose own rulings had
falsified five separate lines, of which a reviewer could see two.

**One real distinction fell out of doing it properly.** `storages` is required **and nullable**, not
required and non-null: `--demo` never runs the storage requirement, so a demo config genuinely
serves `null`. Getting the first fix right forced me to work out that the second was not the same
shape.

---

**And the type change immediately broke three test fixtures that built a `Version` without the
field.** That is not collateral damage, it is the point: a required field makes every construction
site state what the storage is. The fixtures now say `null`. **The alternative — relaxing the type
so the fixtures keep compiling — is how a wire contract quietly becomes whatever the tests already
happened to write.**

---

**A guard worked, and it deserves recording alongside the failures.** `TestReadEndpointsMatchGolden`
failed the moment the wire shape changed, which is exactly its job. Its regenerated diff was one
added field per version and nothing else:

```
-      "missing": false
+      "missing": false,
+      "storage_id": null
```

That is the additive claim **proven by the guard** rather than asserted in a PR body — the same
distinction the migration in `0006_storage` was built around, arriving from the opposite direction.
Two of tonight's three strongest pieces of evidence came from things that fail loudly on their own:
the golden file, and a `pragma_table_info` comparison. Neither required me to remember to check.
