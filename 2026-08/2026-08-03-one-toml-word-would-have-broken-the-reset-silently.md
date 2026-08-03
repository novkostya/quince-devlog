# 2026-08-03 — The public demo became deployable, and the setting that would have silently broken its reset is one word

**`"suspend"` is the natural name for what the Operator asked for and it is the wrong value. It
restores a memory snapshot without restarting the process, so `removeDemoState` never runs — and a
vandalised demo would stay vandalised forever with every gate green.**

Implementer session `r15`. Issues [quince#444](https://github.com/novkostya/quince/issues/444)
(the mode) and [quince#494](https://github.com/novkostya/quince/issues/494) (hosting it).

## What landed

[#605](https://github.com/novkostya/quince/pull/605) — one in-flight device op per **device**,
whatever its kind, on the shipping `deviceops.Manager` as well as the demo provider. The last
unbuilt entry in the public-demo spec's *"what must land before EXPOSURE"* table.

[#606](https://github.com/novkostya/quince/pull/606) — `fly.toml`, `deploy/demo.md`, and the deploy
workflow no agent seat can install.

The Operator created the `quince-demo` app and set `FLY_API_TOKEN` mid-session, which is what turned
quince#494 from a scoping issue into buildable work.

## The finding

The demo's reset guarantee rests entirely on `removeDemoState` running at **process start** — that
is the argument quince#494 itself made for why no scheduler is needed, and
[#575](https://github.com/novkostya/quince/pull/575) gated it, deliberately running the `SIGKILL`
case because a container stop is entitled to be one.

fly offers two scale-to-zero values and they are not interchangeable for that. `"stop"` terminates
the VM and resets the rootfs. `"suspend"` takes a Firecracker snapshot and, in fly's own words,
resumes *"without rebooting the OS or restarting your app."*

**Under `"suspend"` the wipe never runs.** Nothing inside quince can observe the difference: the
process has no way to know it was frozen rather than started. Every test stays green, the login
screen still says the demo resets, and the first visitor's vandalism is permanent. `"suspend"` is
also non-deterministic — snapshots are not guaranteed to persist and ineligible machines silently
fall back to stopping — so it would have produced a demo that resets *sometimes*, which is worse
than either honest option.

## What it cost to nearly get wrong, and what actually did go wrong

**I asserted a blocker that did not exist, and had to correct it on the issue.** I read
[quince#592](https://github.com/novkostya/quince/issues/592) — *"quince serve accepts no connections
for ~36 s"* — and reasoned that scale-to-zero puts that window on the visitor's path, calling it
*"on this issue's critical path"*.

It is not. `--public-demo` implies `demoMode`, which takes the demo branch and **never calls
`buildLiveStack`** — no storage probe, no muxer, no reconciliation, no backup engine, which is every
one of the things quince#592 measured. The code says so in a comment I had already read. Measured
afterwards on a real container: **64 ms** from `StartedAt` to `quince serving`.

I reasoned from a number to a deployment without checking the deployment runs the code the number
came from. **Same defect class this project keeps filing** — a claim asserted about a different
reality from the one measured — and about twenty minutes of deploy design were built on it.

## And quince#592's own diagnosis does not survive its own timeline

Found while chasing the above, recorded where somebody will meet it. The issue attributes the 36 s to
startup reconciliation *"still running"*. Its timeline says:

```
04:42:35  reconcile: ...skipped        ← reconciliation DECLINING to run
04:42:59  quince serving               ← 24 s later
```

That `:35` line is `reconcile: skipping an unreachable storage` (`storage/reconcile.go:25`). So **~24
of the 36 seconds are unattributed**, and the suggestive detail is that the storage on that box was
*unreachable* — the shape that costs a blocking probe. If that is it, the measurement is a property
of that box's absent disk rather than of reconciliation. Nobody has profiled it, including me; this
records that the stated cause is unproven, not a better one.

Its ruled fix — listener first, `/api/health` reports `starting`, everything else `503` — is right
and is about state honesty rather than speed. **It does not shorten the window.**

## Two smaller things worth keeping

**A gate caught a real gap.** `gate-scope-test`'s totality guard failed on `fly.toml`: *"unclaimed
top-level path(s) — would be covered by gates-sh alone, silently."* Claimed as process-only, because
nothing in the tree reads it. Deliberately **not** `product_covered` — that would fire an image
rebuild and e2e on an edit that cannot affect the image, a gate that cannot fail for the right
reason. The consequence is now written in two places: **nothing here validates `fly.toml`**; a typo
is found by `fly deploy`.

**`build-target` takes a hyphen** where every neighbouring fly.toml key takes an underscore, and
flyctl ignores an unknown key **silently** — so `build_target` builds the wrong stage without
complaining. Found by reading flyctl's struct tag rather than the prose docs, which is the only
reason it was found at all.

## Measured, so it is not re-litigated

`.github/workflows/**` returns **`403 Resource not accessible by integration`** to
`quince-coder[bot]`, with the control that makes it conclusive: an ordinary contents write to the
same branch, in the same call, with the same credential, returns `201`. **Path-scoped, not a broken
credential.** Canon's existing measurement was for `quince-bot`, a PAT, so it did not cover the App
seat since `decisions/0014`. It does now, and the answer is unchanged — note the wording differs
(`by integration` vs `by personal access token`), which is how to tell the two apart.

**`quince-review[bot]` remains unmeasured** and declares `workflows: write`. One write from the arch
box settles it and would delete the detour permanently.

## Not established

Nothing is measured against a deployed instance, because none exists. The workflow has never run.
`fly.toml` has been parsed by nothing — there is no TOML validator on the session box. The 256 MB
floor is a choice, not a measurement. And [quince#465](https://github.com/novkostya/quince/issues/465)
stays open: #605 built the single-flight half, and the demo still never deletes from `ops`, so the
map now grows one entry per *completed* op rather than per request — much slower, still unbounded.
