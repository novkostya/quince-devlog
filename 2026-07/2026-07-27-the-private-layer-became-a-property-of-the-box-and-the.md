# 2026-07-27 — The private layer became a property of the box, and the control protecting it had to be built in a different repository than the one it protects

**The private layer became a property of the box, and the control protecting it had to
be built in a different repository than the one it protects.**
[quince#44](https://github.com/novkostya/quince/issues/44) closed by
[quince#81](https://github.com/novkostya/quince/pull/81) (`6594c0b`), completing the pr.7 unit's
fifth PR. `deploy/runner/provision` now clones `quince-local` in full, so a rebuilt box no longer
returns silently to the state where the privacy gate could not run — the founding defect, where
sessions had learned to trust a file a rebuild removed and nothing announced the regression.
**Two Operator rulings, and their coherence is the part worth keeping:** the implementer keeps
**`write`** on the layer because it is a living document an agent must maintain without the
Operator becoming a required hop; and the transport is a **full clone** rather than a narrow fetch,
because an implementer that can *write* `environment.md` but cannot *see* it reintroduces exactly
that hop. The implementer had argued for a single-file fetch on exposure grounds and was **wrong
about the shape of the problem**, having treated the two questions as separable. **One decision was
made inside the ruling rather than inferred past it:** the credential is **role-dependent**, which
the ruling could not have said — the arch box must never hold the bot token, since `preflight`
refuses to start if it does and that inversion *is* the separation mechanism (devlog#7), so each
box clones with its own identity. **The accepted exposure is now written where it will be met:**
both boxes carry the complete private record — ~610 KB across 8 files, including lab topology and
the external review transcripts — not the 107-byte pattern list. `CLAUDE.md` had said the layer
*"exists only on the Operator's machines"*; that had stopped being true and is corrected in the PR
that widened it, with `pr.6`'s credential-concentration boundary recorded as owed. **The residual
risk drove the only genuinely novel piece.** Prevention is unavailable — branch protection on
`quince-local` returns *"Upgrade to GitHub Pro or make this repository public"*, measured, because
protection on private repositories is a paid feature — and narrowing was ruled out, so **detection
was all that remained**, and `privacy-check` refused an EMPTY list while accepting a SHORTENED one.
A trimmed list was silently as good as a full one, by the identity the list constrains. The fix
puts the minimum count in **`quince`, which IS protected**: `deploy/privacy/patterns.floor`. A trim
now fails the gate **on the boxes** until the floor is lowered — via the commit-time sweep a session
runs, and via `preflight`, which delegates to `privacy-check` against the real layer. **Not in CI,
which never sees the real pattern list:** every suite in the ladder runs against synthetic layers,
and the `privacy-check` target that reads the real one is standalone rather than part of `gates`.
A real control, then, but not an always-on independent one — which is the distinction a reader needs
when weighing the residual risk. Lowering the floor is a reviewed
change approved by somebody who is not the author — **the review model restored to the one artifact
that cannot have it, without moving the artifact.** A count rather than a checksum, because a
checksum fails on every legitimate edit until updated, which trains people to update it without
looking. An absent or non-numeric floor is DID NOT RUN, never a pass: *a control that can be
deleted to disable itself is not a control.* **The review's finding was one sentence, and it was
the sentence doing reassurance work.** The floor's comment claimed a count *"only moves when the
list shrinks, which is the only direction that weakens the gate"* — false, and measured before
correcting: three real patterns at floor three catch a planted match, three JUNK patterns at floor
three let the identical match through, same count, gate green. **Substitution weakens it identically
and the floor cannot see it**, and the identity that can trim can equally rewrite. Under a ruling
that says detection is all that remains, a sentence claiming the detector covers *the only*
weakening direction tells whoever weighs the residual risk that it is closed. The file now states
both what it covers and what it does not, and the canary — the natural detector for substitution —
is recorded on quince#44's residual-risk register rather than built, because its probes must match
the private patterns and would live in the same writable layer: the same problem one level down.
**The coupling was caught by the suites rather than by anyone's foresight:** adding the floor broke
`preflight-test`, because `preflight` delegates its verdict to `privacy-check`, whose synthetic
layers carry one pattern against a real floor of nine — the read-the-box trap one delegation
deeper, and `PRIVACY_FLOOR_FILE` became the ninth entry in the unset list that was made a single
variable two PRs earlier for exactly this. **Owed and declared rather than implied:** `provision`
has never been run end to end, because it restarts the service hosting the session that would run
it; its arch branch is unexercised, there being no arch credential on the implementer box by
design; and the `.superseded` rename — a hand-placed layer is moved aside, never deleted — is
untested against a real one. All three are the Operator's re-provision window, which quince#79 made
**more** consequential rather than less: once a box pulls the launchpad, a drifted layer refuses the
next restart. ([quince#81](https://github.com/novkostya/quince/pull/81),
[#44](https://github.com/novkostya/quince/issues/44))
