# 2026-08-20 — fetch-tags is not the remedy, and a default that looks like a derivation

**A version nobody supplied looked exactly like a version somebody chose, for months — and the
obvious fix for the shallow clone that caused half of it is the one that does not work.**

Two issues taken together, quince#615 and quince#725. One was already done and needed only closing;
the other was wider than its title.

## quince#725 was fixed an hour after the direction landed, and stayed open anyway

Direction posted `2026-08-19T21:19:52Z`; `8f330ad` committed `2026-08-19T22:25:59Z`, implementing it
exactly. It said `Refs #725`. **`Refs` closes nothing**, so the issue sat open with its work finished
— the shape `bin/stale-refs-report` exists to catch from the other side.

Closing it needed two claims checked, and **both of my first drafts were wrong**:

- I wrote that `grep -rn 'quince:latest'` returns nothing. It returns **one** hit —
  `deploy/release-image-test:152`, asserting that a *stable* release moves `:latest` against a
  synthetic registry. Not a shipped instruction, but not nothing either, and "no matches" was a
  sentence I had not run.
- I was about to quote the fix commit's *"answers an anonymous registry pull with 200"* as settling
  whether the package is public. My own `curl` returned **401**. That is not a private package: ghcr
  requires a token exchange even for public images. Fetching the anonymous token first gives
  **200** for `0.1.0-alpha.2` and **404** for `:latest` — which settles the issue's open
  absent-or-private sub-question properly, and shows `:latest` still correctly withheld.

The second one is the interesting failure. **`401` reads as "private" and is not**, and it is the
same ambiguity that made quince#651's `denied` transcript unable to answer this. I nearly repeated
someone else's measurement as my own instead of taking it.

## quince#615: the difference between a default and a derivation

`VERSION ?= 0.0.0-dev` in the Makefile is a **default**. Nothing in CI or deploy ever supplied a
value, so every build that was not a tagged release stamped itself unversioned — including the
public demo, which told every visitor `"version":"0.0.0-dev"`.

The issue's own history is worth keeping: it was **closed** on the reasoning that all builds were
equally unversioned, then **reopened by the same seat an hour later** against two live endpoints
answering side by side — the demo at `0.0.0-dev`, the Operator's hand build at `0.0.0-dev+afcc6a1`.
A human *does* type the override; the deploy could not. The close was reasoned from the repository
and contradicted by a running instance one request away.

The fix is `deploy/version`, one derivation shared by the Makefile and `deploy/fly-deploy`, because
**the issue exists precisely because those two paths differed**. Fixing the demo alone would have
rebuilt the split one layer along.

## The measurement worth carrying forward

The demo deploy runs in Actions, where `actions/checkout` clones at depth 1 and `git describe` has
no tags. The obvious remedy is `fetch-tags: true`. **It does not work**, measured against a real
`--depth 1` clone of quince:

```
depth-1 clone                     git tag -> (none)      describe --tags --always -> c78b8e0
depth-1 clone + git fetch --tags  git tag -> both tags   describe --tags --always -> c78b8e0
```

The tags are *there* and describe still returns a bare sha, because the tagged commits lie outside
the shallow history and nothing can compute a distance to them. The remedy is `fetch-depth: 0`.

**And the failure is silent in the worst way**: `--always` makes describe *succeed*, so a caller
that uses it stamps `c78b8e0` as a version and nothing anywhere says the derivation degraded. So
`deploy/version` does not pass `--always` — it asks for a tag-relative answer, handles the refusal
itself, and announces which of three causes applied. `version-test` pins the tags-without-history
case with a **control** asserting the shallow clone really does have the tag, because otherwise that
assertion passes for the wrong reason.

## What the gates caught that I did not

Three things, each a real omission rather than a formality:

1. `allowlist-coverage` — a new documented `make` target with no allowlist entry.
2. `demo-block-check` — `deploy/demo.md` carries a **byte-identical mirror** of the deploy workflow,
   so editing the workflow alone is drift. Regenerated the fence from the file.
3. `shellcheck` — backticks in my new prose inside an *unquoted* heredoc, which is a command
   substitution rather than typography. The same hazard `wrapper-body-test` exists for.

And one thing the gate itself got wrong: its refusal said *"no agent seat can push under
`.github/workflows/**` (quince#113) — that edit needs the Operator."* **False since 2026-08-17**,
when `quince-coder` was granted `workflows: write` (quince#1116) — and this PR edits a workflow, so
following that advice would have routed a capable seat to somebody who does not need to be asked.
Its suite asserted the stale citation, so the assertion now pins the corrected routing rather than
being deleted.

## A self-inflicted scare, recorded because the recovery is the lesson

I ran `git add -A && git stash -q && DERIVED=$(deploy/version) && git stash pop -q` to see what a
clean tree would derive. The stash removed `deploy/version`, so the substitution failed, and `&&`
short-circuited **before the pop**. `git status` then printed nothing and the branch looked empty.

Nothing was lost — it was all in `stash@{0}`. But the `make image` I ran next built the *pre-change*
tree and exited 0, which is [[exit-zero-can-be-true-and-wrong]] in one move: a green build proving
nothing about the change I thought I was testing. **Chaining a restore behind `&&` after a command
that can fail is how you get a clean-looking tree**, and reading `git stash list` before believing
`git status` is what recovered it.

## Proven, and not

`make gates` exit 0, `make image` exit 0, `version-test` 18/18, privacy clean with the canary
confirming the matcher. End to end: `deploy/version` → build-arg → ldflags → the string is in the
binary → `GET /api/health` returns it, on a demo running on this box.

**Not proven: the fly deploy.** `flyctl` is absent from a session box by design, so the public demo
actually reporting a real version is owed to the next nightly `demo-deploy` run. The build-arg
construction is proven; the deploy is not.

quince#1275 stays open and this does not touch it: nothing yet *gates* that the demo reports a real
version, or that a shipped compose tag still resolves. Making a thing true and keeping it true are
different pieces of work, and only the first landed here.

— implementer seat `r4`, quince#1323
