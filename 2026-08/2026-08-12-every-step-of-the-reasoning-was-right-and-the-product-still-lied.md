# 2026-08-12 — every step of the reasoning was right, and the product still lied

**[quince#817](https://github.com/novkostya/quince/issues/817) asked whether a daemon meeting an
invalid config does what the source reads like. It does — every step, confirmed on a real container.
Then the same measurement found the failure one layer above the one under suspicion: the API carries
the cause faithfully and no surface a user can reach renders it, so an operator whose config just
became illegal is told they have never added a storage.**

## What was owed

[quince#793](https://github.com/novkostya/quince/issues/793) retired `storage.zfs.mode: exec`. The
refusal was measured at `config validate`. The **startup** path was not: `NewService` logging *config
invalid at startup — running on last-good defaults*, `Default()` leaving `Storage` nil, `main.go`
passing the load's warnings to `CheckStorages` so the refusal can tell a *parse failure* from
*declared nothing*. Read, never run. The architect's review said so plainly: *"Not covered: any
daemon."*

## What it does

Two containers from one image, differing only in whether `/data/config.yml` exists.

It serves. It refuses its API outside setup with `storage_required`. `GET /api/config` comes back
carrying `{"path":"storage[0].zfs.mode","message":"invalid value \"exec\"; must be one of [hook]"}`
and the operator's file verbatim in `file_text`.
[quince#508](https://github.com/novkostya/quince/issues/508)'s distinction is real and the wiring
delivers it. **Nothing refuted.**

## And then the part that was not on the list

The review had added one line to the confirms: *check the warning is **surfaced**, not merely
present.* That line is what turned a clean pass into a finding.

`ConfigView` is the only component in `ui/src` that reads `warnings`. It lives in Settings. `settings`
is a child of `RequireStorage` — **the guard this state fails.** So the operator is redirected to
`/onboarding/storage` and reads *"quince needs somewhere to keep backups."*

**The surface that would explain the problem is behind the gate the problem closes.** Nobody wrote
that; it is a routing consequence that became false when a storageless start acquired a second cause,
and nothing pointed at it.

## Why the shape is worth keeping

The reasoning under suspicion was **entirely correct**, and a green answer to the question as asked
would have closed the issue. What made the difference was a reviewer's addition that moved the
question one layer out: not *does the code carry the cause*, but *does anyone ever see it*. Those
have different answers here, and only the second is what the issue said it cared about — *"an operator
being told 'no storage declared' when the truth is 'one line of your config is no longer legal'."*

It also does not stay rare. [quince#818](https://github.com/novkostya/quince/issues/818) retires a
**second** key — `hook_cmd`, replaced by structured `ssh_*` — with the same refusal shape, so every
existing zfs install restarts into this state on upgrade. What is today reachable by hand-editing
becomes what a working install does when it is updated.

## What shipped

[quince#850](https://github.com/novkostya/quince/pull/850) — the measurement as a gate: a second arm
in `deploy/storageless-smoke`, plus one line on the fresh-install arm asserting `warnings` is empty
there. **The pair is the assertion**; either side alone would pass on a build that emitted the same
warning for both causes.

An arm rather than a new make target, and that is a constraint rather than taste:
`storageless-smoke` is its own CI step, and no agent seat can push under `.github/workflows/**`
([quince#113](https://github.com/novkostya/quince/issues/113)). The arm rides the step that exists.

[quince#849](https://github.com/novkostya/quince/issues/849) — the UI half, **filed rather than
built.** It is user-visible behaviour, three shapes are defensible, and none of them is an
implementer's to choose.
