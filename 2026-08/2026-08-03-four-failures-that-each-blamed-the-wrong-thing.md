# 2026-08-03 — The public demo took four deploys to come up, and every failure accused something that was fine

**A missing build-arg reported that a git repository did not exist. A missing directory reported a
sqlite errno. A config binding reported a process count. And an approval that survived a rebase
reported itself dismissed. Each one names the wrong thing, and each cost a round trip to read past.**

Implementer session `r15`. Issue [quince#494](https://github.com/novkostya/quince/issues/494).

## What landed

[#605](https://github.com/novkostya/quince/pull/605) and
[#609](https://github.com/novkostya/quince/pull/609) closed
[quince#465](https://github.com/novkostya/quince/issues/465) — the last open entry in the
public-demo spec's exposure dependency table.
[#606](https://github.com/novkostya/quince/pull/606),
[#608](https://github.com/novkostya/quince/pull/608),
[#611](https://github.com/novkostya/quince/pull/611) and
[#614](https://github.com/novkostya/quince/pull/614) took the deploy from "nothing exists" to an
image that starts.

## The four misleading failures

**1. `Service has no processes set but app has 1 processes defined`.** I had written a comment
asserting that naming the process group `app` — fly's default — meant the service needed no
explicit binding. It does not. flyctl requires `processes = ["app"]` whenever *any* `[processes]`
block exists. The research I based it on described the naming rule correctly; the inference was
mine, and nothing between me and the deploy could tell the difference.

**2. `fatal: repository '/src/netmuxd' does not exist`.** The best of the four. `flyctl` knows
nothing about `versions.env`, so every ARG the Dockerfile declares without a default arrived empty.
With `NETMUXD_REF` empty, `--branch` swallows the URL and git reads the **destination** as the
repository — so an unset variable presents as *"that repository does not exist"*, accusing the one
path on the line that was never in question. Nine stages of the build looked healthy first, because
the image-ref ARGs *do* carry defaults.

**3. `open db /cache/demo.db: unable to open database file (14)`.** The image sets
`QUINCE_DATA=/data QUINCE_CACHE=/cache` and creates neither, so it cannot start. The fatal line is a
sqlite errno naming neither the missing directory nor the variable that pointed at it; the two lines
that say what is actually wrong are `WARN`s above it.

**Nothing had ever run this image as-is.** `make demo` overrides both to `/tmp`; both compose files
bind-mount over them, and a bind mount creates its target. Every existing path either replaced the
values or covered the paths, so the declared defaults were **dead config that read as live**. The
fly deploy is the first thing to run the image in the configuration its own `ENV` line describes.

**4. `reviewDecision: REVIEW_REQUIRED` immediately after a rebase**, with the head OID unchanged —
which looks exactly like a dismissed approval. It was quince#523's known `headRefOid` lag. Eight
seconds later: head moved, review still `APPROVED`. Reading it twice cost nothing; reporting the
first answer would have sent someone to re-approve a PR that was already approved.

## The pattern, since four in one evening is not a coincidence

**Every one of them reported a true fact about the wrong layer.** git really could not find that
repository. sqlite really could not open that file. The API really did return `REVIEW_REQUIRED`.
None of them was a lie, and none of them named its cause. The habit that worked was *read the
adjacent line* — the `WARN`s above the fatal, the `--branch` argument before the URL, the second
API read after the first.

## Two guards earned their keep

`gate-scope-test` refused `fly.toml` as an unclaimed top-level path; `sh-lint-coverage` refused
`deploy/fly-deploy` as an unlinted shell file. Both are totality guards, both fired on the first run,
and both wanted a *decision* rather than a green light. `fly.toml` is claimed process-only —
deliberately **not** `product_covered`, which would fire an image rebuild and e2e on an edit that
cannot affect the image, a gate that cannot fail for the right reason.

**What is therefore ungated is written down in both places: nothing in this repository validates
`fly.toml`.** A typo is found by `fly deploy`. That is accepted rather than overlooked, because the
only real check needs a credential no gate can hold.

## Where I was wrong, twice, and the second one nearly became a filed bug

**I called quince#592 a blocker for this deployment and it is not.** `--public-demo` implies
`demoMode`, which never calls `buildLiveStack` — so no storage probe, no muxer, no reconciliation,
none of what that issue measured. Measured afterwards: **64 ms** to `quince serving`. I reasoned
from a number to a deployment without checking the deployment runs the code the number came from.
Corrected on the issue.

**Then I nearly filed a bug against quince#575's merged story-7 gate.** I tested the reset by
counting versions across a `SIGKILL` restart, got 5 where I expected 6, and briefly believed the
reset was broken. **My invariant was wrong, twice**: the demo runs a live timeline so the count
moves with uptime — a fresh container read 5 while the older restarted one read 6, which is the
inversion that gave it away — and version ids are ULIDs minted per run, so they cannot be checked
for either. The valid measurement was the state file's identity: inode `325449` → `326067` after a
`SIGKILL`. `removeDemoState` ran. The test was right.

**The lesson is not "be careful."** It is that a moving number makes a convincing invariant, and
both wrong measurements produced a *specific, plausible* result rather than an obviously broken one.

## The thing worth keeping from the whole evening

Running the image the way the platform runs it — no mounts, no env overrides — took one command and
found a bug that four deploys, every gate, and two compose files had never exposed. It also settled
[quince#444](https://github.com/novkostya/quince/issues/444)'s central question by measurement
rather than argument: over plain http the session cookie carries no `Secure`; with
`X-Forwarded-Proto: https` it does. The deployment shape delivers the flag, with no code and no
change to `--demo`.

## Not established

Nothing has been deployed successfully — the crash loop is fixed and the next attempt is the test.
**256 MB is a choice, not a measurement**, and it is the next thing that can fail. Cold-start latency
behind fly's proxy is unmeasured. The workflow has still never been installed by the seat that wrote
it, and `quince-review[bot]`'s `workflows: write` grant remains the one unmeasured capability.
