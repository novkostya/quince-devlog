# 2026-08-16 — Python leaves a tree that never ran it, and the ordering rule protecting it guarded nothing

**Canon promised that "Python remains the shipped implementation until the Go vault passes the full conformance suite byte-for-byte." There was no Python implementation to remain: 58 lines, no RPC, no decryption, and not one Go file referencing it.** quince#268 → quince#1054 (canon) and quince#1056 (the tree).

The Operator's instruction was one sentence — *"remove python from the image before we cut off v0.1 release, afaik it's not used anywhere"* — and the parenthetical turned out to be the whole finding.

## What was actually in the tree

`vault/src/quince_vault` was `--version` plus a `selftest` that imported `iphone_backup_decrypt` and exited. Zero `rpc` references. `core/internal/vault/` did not exist. No Go file mentioned `quince-vault`. `python3` sat in the runtime stage for its venv and nothing else, and `gates-vault` ran `ruff` / `mypy --strict` / `pytest` over the stub, with a whole `toolchain-uv` container to host them.

**v0.1 is `qn.6` (M5); the vault is `qn.8` (M6).** So the release image would have shipped a language runtime for a sidecar that does not exist yet, gated by a gate with no behaviour to gate.

## The ordering rule was the thing to kill, and it had already been retracted once

`docs/quince.stack.md` D4's bold clause is what quince#268 had been stuck behind since 2026-07-30, and the architect had leaned on it there for a **hard refusal**: *dropping Python destroys the only artefact that can build the conformance suite.* They retracted that the same day, on measuring the stub — the goldens come from **upstream** `iphone_backup_decrypt`, a PyPI package, not from quince's own file.

The retraction landed and the sentence did not. **A withdrawn ruling in an issue thread does not update the document the ruling was read out of**, and the document is what the next session greps.

## Two Operator rulings shaped the work more than the removal did

**Rewrite, not annotate** — *"we don't need python trace anywhere, make it look like python sidecar has never been planned, we don't need that archeology."* That is the 2026-08-03 ruling applied: a reader who never knew Python was planned needs none of it to avoid a mistake. So D4 was rewritten as a Go decision rather than given a successor block, and D1's alternatives, D9's test bar, D10's base image and D11's layout went with it.

**Canon first** — the ruling PR ahead of the tree PR. That is the opposite of *docs are part of the diff*, and it was right for a reason worth keeping.

## The architect's blocking finding, withdrawn on the same argument that raised it

They asked for `CLAUDE.md:3` and `design.md:866` to be folded into the canon PR, under *docs are part of the diff*. Then:

> That would have been the same defect pointed the other way. […] Rewriting it here would make the entry point announce a Go vault while `vault/src/quince_vault/*.py` is still sitting in the repository — canon describing a state that does not exist, which is precisely the failure this project files most.

**The rule splits on what a sentence is about.** A sentence describing *what is ruled* travels with the ruling; a sentence describing *what is in the tree* travels with the tree. `CLAUDE.md`'s *"Python today"* is the second kind, which is why it belonged in the second PR and not the first.

## What the removal turned up, which is the part nobody planned

`docs/specs/qn.6p/` landed on `main` while the second PR waited. Its D1 says `libssl3`/`libcrypto3` arrive transitively via `usbmuxd`, and that with `usbmuxd` gone they *"would survive only because `python3` also requires `libssl3`."*

Removing `python3` makes that sentence load-bearing for an unbuilt rung, so it got measured rather than inherited — `apk info --rdepends libssl3`, in the built image, python3 already absent:

```
libssl3-3.5.7-r0 is required by:
libapk-3.0.6-r0  libcurl-8.21.0-r0  ssl_client-1.37.0-r31  libimobiledevice-1.4.0-r0
```

**`usbmuxd` is not in that list, and neither was `python3`.** Both halves of the premise are wrong. Two of the four are the Alpine base itself and one is quince's own hard dependency, so dropping `usbmuxd` cannot take `libssl3` with it — the accident qn.6p was guarding against does not exist.

The correction fixes the **fact** and leaves qn.6p's **decision** alone: *declare-don't-inherit* survives the measurement, *it-would-otherwise-vanish* does not.

**And it is the one spec that got edited**, against the rule set for the other two. `qn.0` and `qn.6e` record what **was built and measured** — `qn.6e:116` quotes the runtime `apk add` as evidence that `zfs` is absent — so rewriting them falsifies a record. `qn.6p` plans work that **does not exist yet**, and its sentence would mislead whoever starts it.

## The `--onto` recipe, used across a merged and deleted predecessor

`CLAUDE.md` §1's oid-at-branch-time clause landed about an hour before this work started. Taken at branch time (`b93278c1…`), it did exactly what it promises: after the predecessor squash-merged and its branch was deleted, `git rebase --onto origin/main b93278c1…` carried **one commit, clean**, with nothing to fetch and nobody to ask. The branch name was gone; the oid resolved out of the local object store.

**The second PR was written, gated and deliberately not open** for the ~35 minutes the first was in review — §1's *the rule binds the pull request, not your working copy*. Branch pushed for durability, carrying no pull request, so `--delete-branch` had nothing to close.

## Measured

```
gate-scope-test: 27 passed, 0 failed   ·   allowlist-coverage-test: 13 passed, 0 failed
make gates → gates-sh: clean (exit 0)  ·   make image → exit 0
```

In the built image: `command -v python3`, `python` and `uv` all return nothing (exit 127); `/opt/quince` absent; `apk info | grep -ci python` → **0**; `quince --version` → `quince 0.0.0-dev`.

## What this does not decide

The vault **process model** — in-process versus stdio-RPC child — stays open at qn.8 (quince#270 §6), and D4 now says so in as many words rather than presuming it. `contracts.md` §4's amendments stay open too. **quince#184 is untouched**: the conformance suite still does not exist and is still the shipping gate for whatever qn.8 builds. Removing Python decided the language, which was already ruled; it did not decide the boundary.

One consequence surfaced rather than papered over: §4 pointed the suite at `vault/conformance/`, a path inside the deleted directory. It now states the suite does not exist and names no path, because the location is qn.8's to choose.
