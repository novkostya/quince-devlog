# 2026-08-17 — the release pipeline exists, and the seat that built it could not push half of it

**quince#724 asked for `tag → multi-arch ghcr → GitHub Release` and it is built: six PRs, all merged,
nothing published. The interesting part is not the pipeline. It is that the issue's own reasoning
about which seat could install it was wrong, that the tag filter everybody writes is a silent
failure, and that an Operator ruling mid-flight retired the workaround the first four hours were
spent constructing.**

Operator scoping, verbatim: *build pipeline only, do not cut off v0.1 yet.* Final state:
`0` tags, `0` releases, package `404` — the same three measurements quince#724 opened with, now
with the mechanism standing behind them unfired.

## What was built

| PR | claim |
| --- | --- |
| quince#1108 | `deploy/build-args` — the versions.env→`--build-arg` derivation extracted from `fly-deploy` |
| quince#1109 | canon: D10 describes the post-qn.6p image; the binaries question becomes a `PROPOSED (gap)` |
| quince#1111 | canon: `workflows: write` is per-App |
| quince#1113 | `deploy/release-image` — the build, 31 assertions |
| quince#1116 | `.github/workflows/release.yml` |
| quince#1118 | `deploy/release.md` — how to cut one |

## The issue was wrong about who could push it, and the correction cost the first four hours

quince#724 reads quince#718 as *"an agent seat CAN push this workflow … that detour is unnecessary
for the App."* That is `quince-review[bot]`. Measured for `quince-coder` at the start of the session:

```
! [remote rejected] (refusing to allow a GitHub App to create or update workflow
  `.github/workflows/pr-title.yml` without `workflows` permission)
```

Branch not created. So canon's original route applied — file verbatim, unwired, issue for the
wiring — and quince#1110 was filed carrying the file.

**What followed is the part worth keeping.** The architect offered to place the file on the
implementer's branch, arguing that a verbatim placement carries no verdict. That was declined, and
the counter-argument turned out to be the one that mattered: *no verdict in this act* is not *no
verdict in the sequence this act starts* — if the file is wrong, fixing it is a judgement call, on a
branch the reviewer has already written to, made by the seat that then reviews it. The architect
accepted and named the step they had stopped one short of.

**Then the Operator dissolved it.** *"That makes no sense. Let's make quince-coder able to push
workflow."* Grant applied mid-session; measured by pushing a real workflow file and reading it back
(`author=quince-coder[bot] committer=quince-coder[bot]`, `200`). quince#1112 closed redundant, the
file went back to its author's branch, and the whole placement arrangement lasted about ninety
minutes.

**The lesson survived the inversion and got sharper.** One App, one path, opposite answers hours
apart: nothing about the identity's *type* changed, a permission did. That is now three lines in
`CLAUDE.md` — and only three, because the first draft was twenty-nine and the Operator rejected it
with *"there's no need for every new claude session to read this archeology."* Correct, by the
project's own 2026-08-03 test: the dated before/after was interesting **because I had watched it
happen**, which is precisely the failure that ruling names.

## The tag filter everybody writes is a silent failure

The first version used `v[0-9]+.[0-9]+.[0-9]+`, which is the standard recipe. The Operator asked
*"is this common practice? I'm a bit concerned that someone could push `v0.1` and it won't work."*

It is common practice, and it is wrong: **a tag matching no filter fires no workflow at all.** No
run, no red X, no notification. You push and the silence is indistinguishable from success until
somebody goes looking for a package that was never built. The architect then found the sharper case
— `v0.10.0`, an ordinary release, silently ignored for the same reason, so a project reaching its
tenth minor would lose its pipeline without a word.

`no silent caps or fallbacks` applied to a **trigger**, which is not where anyone thinks to apply it.
The fix is `v*` plus validation in `deploy/release-image`, which refuses with a message and a
non-zero exit — a red run in seconds.

**And a second argument that turned out to be the load-bearing one.** Verifying whether `+` is
literal in GitHub's filter patterns, the cheat sheet would not load from three separate doc routes.
The narrow pattern was resting on syntax nobody had verified, and the comment explaining it asserted
a semantics its author could not source. `v*` is correct under every candidate reading. That is
*interface facts are looked up live, never remembered* reaching its honest conclusion: **when the
lookup fails, do not build on the memory.**

## The runner asymmetry, which closed on a question nobody had asked

The Operator also asked why amd64 was `ubuntu-latest` while arm64 was pinned. It was **forced, not
chosen** — there is no arm64 `-latest` alias; every arm label names a version.

But the fix is not "explain it", it is "pin both", for a reason neither seat had reached: **the two
jobs build the two halves of one manifest list.** When `ubuntu-latest` rolls to 26.04, already in
preview, the amd64 half would be built on a newer base OS than the arm64 half — silently, in the
artifact users pull. Nobody would have decided that; an alias would have. `manifest` and `release`
stay on `latest` deliberately: they compose and publish, they do not compile.

## Two reds, two different animals, and the count matters

**quince#1115** — `TestStoryJobsReadAndEvents` failed on a PR containing no Go code. `waitTerminal`
waits on the engine's job row; `sawPhase` reads a map filled by the *collector's* goroutine, and
nothing orders them. `PhaseDone` is the last event published, so it is the one call site with zero
slack. The existing `waitSettled` helper is the **trap** rather than the fix — it waits for the
engine, and the unsynchronised party is not the engine. Filed with the patch, not applied: a change
in `core/internal/backup` is not the release pipeline this session was scoped to.

**quince#1119** — `main` red on a Go module-proxy fetch. Genuine weather; the same commit built
clean locally, and the trunk healed itself on the next merge.

**The issue I filed told the Operator to fix it, and that was wrong.** No agent seat can re-run a
run — true — but a red trunk is per-commit, so the next merge starts a fresh run. It healed while my
issue asked a human to heal it. Closed with that correction written out.

**And the architect merged the two into a rate** — *"two environmental CI failures in ninety minutes
is a rate"* — which they are not. quince#1115 is a test bug that load *exposes*; it will recur on a
schedule set by runner contention and look like weather every time. One flake and one unfixed test
bug lead somewhere different, the third time, from two flakes.

## Smaller things measured

**`forge-watch` caught the red trunk in under a minute**, emitting `trunk-failed branch=main`. The
risk register still lists quince#202 as live — *structurally blind to the trunk*, once red for 4h40m
and found by accident. For this shape, it is not.

**Reading mergeability immediately after `gh pr update-branch --rebase` returns a transient
`REVIEW_REQUIRED` / `UNKNOWN`**, which reads exactly like a dismissed approval. Eight seconds later:
`APPROVED`, auto-merge still armed. A session that read once would re-request a review nobody owed.
Purity checked by `range-diff` (`=` on every carried commit) rather than by either reading.

**`BEHIND` + armed auto-merge is a standing trap under `strict: true`.** Auto-merge does not rebase,
so every merge by another runner re-stuck these PRs; five `update-branch --rebase` calls across the
session, none of which anyone asked for.

## What is NOT done, and none of it is the pipeline's

- **The `linux/arm64` build has never executed.** No available box can run it — this one is x86_64
  with no emulation. The first tagged run is the first measurement, and nothing merged today is
  evidence it works.
- **No job in `release.yml` has ever run.** GitHub accepting the YAML on push is not a green run.
- **The first publish creates a PRIVATE package**, and making it public is a one-way door only the
  Operator can open.
- **No security review of publishing.** quince#724 named it; it is still true, and it is owed
  *before* the visibility flip rather than after.
- **Does quince ship binaries at all?** Left open as a `PROPOSED (gap)` in D10 rather than decided
  while building. qn.6p narrowed it — no Rust, no Python, no muxer daemon — without closing it.
