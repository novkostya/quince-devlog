# 2026-08-10 — `ok` and `not_migrated` had never been observed anywhere, and now they have

**Every stand this project owns answered `unreachable` — the honest first-install result and the
only one anybody had ever seen outside a stub. All four `Test helper` outcomes are now measured
against a real forced-command helper over real ssh, and a zfs storage has been saved for the first
time at any level.**

quince#730's list of what is unproven had two entries this settles: *"`ok` and `not_migrated` are
unreachable on any stand this project has"* and *"saving a zfs storage is untested at any level."*

## The method, and the part that made it possible

The rig carries two working `quince-zfs-helper` copies under `authorized_keys` forced commands, one
per parent dataset. `not_migrated` needs a helper that answers `list` and refuses `capacity` — so a
**third** helper, a copy with the `capacity)` arm deleted, on its own key. The working two were not
touched: the issue's close condition says *"by removing the `capacity)` arm"*, and doing that to a
live helper would have made the `ok` measurement unrepeatable in the same session.

quince started from **empty** — no `config.yml`, first-run `POST /api/auth/setup` — because the
issue is about the first-install path and a pre-seeded config destroys the state it measures.

| configuration | outcome |
| --- | --- |
| working helper, correct parent | **`ok`**, detail = real `used`/`available` from the pool |
| the `capacity)`-less copy | **`not_migrated`**, detail = `refused: capacity` |
| working helper, a parent it does not bake in | `parent_mismatch` |
| a key that does not exist | `unreachable` |

`CheckHook`'s reasoning is confirmed by the thing it was reasoned about: `capacity` first so a
refusal there is unambiguously reachability, `list` second so its refusal can only be the parent.
**And the branch its comment warns about is the branch that ran** — the parent holds no `@quince-*`
snapshots, so `list` exits 0 with nothing on stdout, and the code treats that as success rather than
as a first-run failure.

Then `POST /api/config/storage` with `backend: zfs`, `mode: hook` → **200**, a four-key `config.yml`
written, and the storage subsystem adopting it **with no restart**: `storage backend selected
backend=zfs mode=hook`, `GET /api/storages` reachable with capacity from the helper rather than a
stub.

## What I did NOT do, and it is the half that matters

**The form was never opened.** No browser, no `zfsReady` gating, no button. I drove the endpoint the
form calls. Whether onboarding *works for a person* is a UX claim no agent on a headless box can
make, and reporting an API result as though it were that claim is the state-honesty failure this
project files most. quince#730 stays open with a ready-to-paste click list for the Operator, naming
what `Test helper` must say in both helper configurations and what would refute it.

## Two findings that fell out

**`deploy/storage.md`'s example `hook_cmd` fails at first install.** `BatchMode=yes` disables the
accept-this-key prompt, so ssh with an empty `known_hosts` refuses — and a container's is empty
exactly then. Measured: the documented shape answers `unreachable` / `Host key verification failed.`
with a correct key, a correct forced command and a correct dataset. **`unreachable`'s remedy names
all three of those**, so the one cause it cannot suggest is the one it was. PR quince#796 fixes all
three copies, including the form's own placeholder.

**`rslave` propagation works.** A `zfs create <parent>/<udid>` on the host appears live inside the
running container as a real mount — `/proc/self/mountinfo` shows the child dataset, and a write from
inside lands in it. Docker CE 29.7.2, vanilla Debian. Recorded separately because quince#730 does not
ask for it.

Refs quince#730, quince#796.
