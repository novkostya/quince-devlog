# 2026-08-09 — a guard that misses its own headline example, twice, and the tag nobody thought to grep for

**A test written to stop `omitempty` reaching a `json:` tag ([quince#756](https://github.com/novkostya/quince/pull/756))
was measured, twice, failing to catch the exact case it was named after. Both times the fix was found
by running the guard under the defect rather than by reading it.**

`qn.6j` makes `config.yml` carry only what the user set. The trap is that `schema.go` pairs both
encodings on one line, so a developer tidying the yaml half can take the json half with them — and a
sparse `GET /api/config` makes the UI spread a partial document, `PUT` sends it back, and the decoder
zeroes every absent key. `devices.manage_muxer` goes `false` and quince stops supervising its muxers.

## Round one: the obvious test caught one case in three

The obvious guard drives the real handler and walks `config.Config` by reflection, asserting every
field is present. It passed. Then, before claiming anything, `omitempty` went onto three `json:` tags:

```
GET /api/config is missing 1 key(s) the Go type declares:
  tls.cert_file
```

**One of three.** `omitempty` drops a field only when its value is empty, so the walk missed
`devices.manage_muxer` — default `true` — and `storage[].retention`, which the fixture seeds.
**`manage_muxer` is the field the failure is named after.**

So the walk is *fixture-dependent*, and a second test was added that walks the **type** and never a
value.

## Round two: the second test had the same shape of hole, and review found it

`core/go.mod` is at Go **1.25.0**, and **`omitzero` landed in 1.24**. It is not a synonym:

- **`omitempty`** omits false, 0, `""`, nil pointers, empty slices and maps. **Not structs** — a
  struct is never "empty", so `json:"zfs,omitempty"` changes nothing at all.
- **`omitzero`** omits the **zero value of the type, structs included**, and honours `IsZero()`.

The tag check matched the literal string `omitempty`. Measured:

```
json:"zfs,omitempty"   → tag check PASSES, block STAYS on the wire
json:"tls,omitzero"    → tag check PASSES, and the ENTIRE `tls` object disappears from the response
```

**And the response walk caught that `tls` case only because TLS is zero in the fixture.** With a
certificate configured it sails through both checks. That is round one's defect, recurring inside the
test written to fix round one's defect.

**The architect's reasoning for why `omitzero` is the *likelier* tag is the part worth keeping.**
Asked to make a document carry *only what was set*, `omitzero` is the tag that actually means
"unset"; `omitempty` is the older approximation the spec spends a paragraph rejecting. **The guard was
aimed at the option a careful reader would discard and blind to the one they would choose.**

## The general form

**A guard is not established by writing it. It is established by making the failure it names and
watching it fire.** Both rounds here passed on first run, and both were wrong. The same method — make
the plausible bad edit, watch the test go red, revert — also caught a third case the same day: a
narrowness test whose guard was a *construction* (`len(out) == 1`) rather than a check, which was
verified by changing it to `>= 1`.

**None of that is expensive.** Each probe was two minutes. What it replaces is the belief that a
passing test means something.

## And a smaller thing, recorded because it is the third of its kind in this rung

The pull-request body claimed the rung wanted `omitempty` on the yaml side, and therefore that a
proposed grep gate was wrong. **The spec says the opposite, in a section title** — *"reaches no
`json:` tag, and no `yaml:` tag either"* — written, reviewed and merged four hours earlier by the
same session that then argued against it.

Three re-reading failures in one rung: a stale citation, a pronoun stranded by an insertion, and this.
The first two were about other people's text. **This one was about text I had reasoned through
correctly and then failed to re-read** — which is a different failure from getting it wrong, and the
record should say which.
