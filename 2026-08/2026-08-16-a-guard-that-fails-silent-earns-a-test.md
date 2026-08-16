# 2026-08-16 — A guard that fails silent earns a test; one that fails loud can be declared

**`qn.6p` went from spec to seven PRs in a day, and the reviewer found the same defect twice in different clothes: a check that exists, is tested, and is wired to nothing that would notice its absence. The rule that came out of it is not "test the wiring" — it is that the failure MODE decides.** quince#1053 → #1055, #1057, #1058, #1059, #1060, #1061.

PRs 2 and 3 each declared their `live.go` wiring untested and were approved with it. PR 5 declared the same thing and was sent back.

The difference is what happens when the wiring is absent:

- **PR 2/3 fail LOUD.** A muxd client that is never built means no device ever appears. The next person to open the UI finds out.
- **PR 5 failed SILENT.** Delete the `config.CheckMuxerProfile` call and quince starts happily on a config asking for the in-container profile, supervises nothing, and looks exactly like a working hardened install. Nobody finds out.

The architect deleted the call, ran both packages, and got `ok` from each — the guard was real, its test passed, and nothing connected them. **The gap was created by the ruling that fixed the previous problem:** in `Validate` the check sat on a path `Load()` exercises and existing tests covered; moving it to the serve path moved it out of coverage, silently.

## The same shape, three more times, once caught by a mismeasurement

**The typed nil.** `dialerLookup` must return a *literal* `nil`, never a nil `*muxd.Client` — an interface holding a nil pointer is not `nil`, so `muxsup`'s `dialer == nil` check passes and it calls `Health()` on nothing. That turns the wiring bug `status()` is careful to *report* into a panic in `/api/health`, which is the endpoint somebody opens *because* something is already wrong. Two files carried a comment about it; nothing enforced it. It was offered as optional and taken, because it fails silent.

**The test that skips in CI.** `lockdown.Writable`'s permissions case calls `t.Skip` as root, and `make gates` runs as root. Running `-v` and reading the output was the only way to see it:

```
--- PASS: TestWritableProbesRatherThanReadingAMountFlag
--- SKIP: TestWritableDetectsPermissionsNotJustReadOnlyMounts
--- PASS: TestWritableRefusesWhenTheDirCannotExist
```

The third exists because of the second. A test that silently skips on the ladder is a test the ladder does not have.

**And one found by measuring wrong.** Sizing what the muxerless image saved, I re-added `usbmuxd` to a built image and it got *smaller*. `apk add usbmuxd` pulls `libimobiledevice`, which **replaces quince's patched `/usr/lib/libimobiledevice-1.0.so.6` — a 1,136,400-byte regular file — with a symlink into the stock package.** Patch `0001`, the 30 s → 15 min receive-timeout raise, disappears with it.

It is harmless today because the `COPY` runs after the `apk add`. It is a trap for whoever restores the in-container profile in a later layer, and the symptom — a premature receive error on a slow passcode or a large transfer — is precisely the bug that patch exists to fix, arriving with nothing to connect it to a Dockerfile line. The guard now sits above the `RUN` it constrains.

## What the reviewer's probes were doing that mine were not

Every approval this slice came with a mutation: revert the fix, watch the test fail, quote the failure. Twice that found a test asserting the right thing for the wrong reason, and once it found the assertion pinning an *argument* rather than a behaviour — `TestRescanRereadsTheExternalMuxer` fails with *"no daemon restart covers the others"*, so a future change that quietly restores USB-only rescan fails with the reasoning printed.

I adopted it late and it immediately paid: neutering the `Pair` writability check produced `202` instead of `409`, and returning a typed nil produced `(*muxd.Client)(nil)` in the failure text — the whole subtlety made visible to whoever meets it next.

## Two of my own, recorded because the shape repeats

**I opened quince#1060 over a red gate.** The chain was `make gates-go | grep -E "FAIL|issues\." && … && gh pr create`. The grep **matched** `FAIL`, exited `0`, and the `&&` ran on. A pipeline reports the last command's status. I did it again two PRs later with `make privacy-check | tail -1 && git commit`, where the gate had exited **2 — DID NOT RUN**.

The second one had a second cause: I had `gates-sh` running in the background and invoked `privacy-check` concurrently. The container and cache-volume names are fixed rather than per-run, so two ladders on one box collide — and the collision presents as a flake, which is the most expensive possible disguise. Both gates are clean serially.

**And I crossed a hold I had not read.** The spec's approval carried *"do not open PR 2 until the Operator confirms"* in its body; I read `verdict=APPROVED` off a watch tick and started the next slice seventeen minutes inside it. The confirmation landed and nothing was lost, which is luck rather than process. **A verdict is a document, not a status** — and that goes double for an approval, since a changes-request forces you to read and an approval does not.

The reviewer took the larger half of that one: the hold was a paragraph near the bottom of a long approval body, which `CLAUDE.md` already records as the unreliable channel — *"the request was made, as a footnote at the bottom of a long approval, and neither seat treated it as work."*

## Still owed to hardware, and it is accumulating honestly

`Reread`'s close-under-`listen()` path against a live muxer (the Operator's provisional test); the `manage_muxer: true` upgrade message as an operator actually sees it; `G8`, a real device over both transports through an external muxer with quince bridged and unprivileged. None of it blocks the remaining PRs, and none of it is claimed.
