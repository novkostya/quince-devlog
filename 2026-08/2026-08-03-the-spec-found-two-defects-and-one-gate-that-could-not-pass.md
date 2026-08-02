# 2026-08-03 — writing the `qn.6d` spec found two live defects and a gate that could not have passed honestly

**Reading the tree to write a spec is not overhead before the work — on this rung it WAS the work.
Three findings, none of which the rung issue could have known, and all three came from checking
things the issue stated confidently.**

`qn.6d` — *storage becomes visible* (quince#443) — opened at `r13`. Spec PR
[quince#573](https://github.com/novkostya/quince/pull/573), open questions
[quince-devlog#197](https://github.com/novkostya/quince-devlog/pull/197). **Parked on code** until
the two contract gaps are ruled.

## The two defects

**[quince#569](https://github.com/novkostya/quince/issues/569) — `unreachable_code` emits values
that are in no contract and no TypeScript union**, and one of them is the *most common* failure
there is. `live.go:298` stringifies the internal `Resolution` straight onto the wire, so an
**unmounted disk** emits `unreachable` where `contracts.md`, `wire/objects.go`, `types.ts` and
`qn.6c`'s own ruled text all say `path_unreachable`. `corrupt_marker` is in no union at all.

**[quince#570](https://github.com/novkostya/quince/issues/570) — an unreachable storage has an
EMPTY `id`, so the Re-check button cannot address the only storage it exists for.** Measured with a
throwaway `go test` rather than reasoned:

```
unreachable    → resolution="unreachable"    storage_id=""
missing_medium → resolution="missing_medium" storage_id=""
```

`st.StorageID` is set on only two of six resolutions. The button exists for one scenario in the
ruling's own words — *plug the disk in and press the button* — and the storage you press it for is
unreachable **by definition**.

**Both were latent, and `qn.6d` is where they stop being latent**, because a storage card is the
first surface that branches on the code to pick a remedy, and Forget is the first that must address
a storage the user cannot reach.

## The gate that could not have passed honestly

quince#443's **G1** asks `ui-e2e` to prove two storages sharing a filesystem do not each claim its
free space as their own. **It cannot.** The demo provider *fabricates* both storages and both
numbers, and its two paths share no filesystem — a green e2e there would have answered *does the
card render two numbers* and nothing about the claim.

Split into **G1a** (a Go test over two directories in one `t.TempDir()`, which is the actual claim)
and **G1b** (the rendering half, which is what e2e can answer). This is `qn.6f`'s recorded lesson —
*a thing can run and still answer a narrower question than the one asked* — applied **before** it
cost anything rather than after.

## Why quince#570 is worth more than a bug

**It decided a design question on evidence instead of taste.** Gap B asks how a storage is
forgotten, and the two candidates — `DELETE /api/storages/{id}` versus a config mutation — are both
defensible on architecture. The measurement settles it: a user most wants to forget a storage that
never came up, and **a delete-by-id structurally cannot address one**. The config `name` can,
because it is the config's own key and the DB's primary key and exists for every declared storage
whether or not quince ever reached it.

The re-probe path had already reached the same conclusion and written it down — `live.go:209`:
*"It re-resolves by NAME, which is the identity the config carries."* Nobody had carried that
forward to the API's identity choice.

## Three times today an exit code was true and the claim behind it was false

Worth recording together, because they are one shape and this project keeps paying for it.

1. **`make … | tail` then `${PIPESTATUS:-$?}`** reports **`tail`'s** exit under BusyBox `ash`. I
   read a gate as clean from the wrong process. Re-read every gate by redirecting to a file and
   taking `$?` from the command itself.
2. **A wait-loop polled for the wrong container.** It watched for a `toolchain` container, but
   `gates-sh` runs in `alpine:3.24` — so it exited early and reported *"gates ladder finished"*
   while `make gates` was still running. Caught by comparing the output file's mtime to the clock,
   not by the loop.
3. **Four of 35 file:line citations in the spec were wrong**, and two more were invalidated **by
   the spec's own PR** — inserting the gap blocks into `contracts.md` shifted every line below
   them. Those are now cited by section, because a line number into a file the same diff edits is
   stale by construction.

None of the three was careless and all three produced something that looked like proof. **The
countermeasure that worked was the same each time: check the artifact, not the tool that made it.**

## What is owed

Gap A (the `Storage` object gaining space and counts) and gap B (Forget's shape, with the restart
question folded inside it) are `PROPOSED (gap)` blocks in `contracts.md` and open questions 2 and 3
on the dashboard. **No `qn.6d` code PR opens before both are ruled.**
