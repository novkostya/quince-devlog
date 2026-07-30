# 2026-07-30 — `provision` mapped a ROLE to a FILE, the file stopped existing when the identity moved, and the private-layer section went inert on a live box — kept working only by an…

**`provision` mapped a ROLE to a FILE, the file stopped existing when the identity moved,
and the private-layer section went inert on a live box — kept working only by an undocumented
hand-repair.** `LAYER_TOKEN="$_role_token"` meant `implementer -> quince-bot.token`; `decisions/0014`
moved that identity to a GitHub App key, so on a current box the guard took the skip branch and
`provision`'s documented repair path was closed. The layer stayed fresh because somebody had wired the
helper to `gh-coder` by hand — load-bearing, and recorded nowhere. **The role→file mapping was the
defect, not its implementer half:** pointing at a different FILE would rot the next time an identity
moves, and that is already scheduled (quince#253). Operator ruling, three parts, all taken: the
credential is chosen by asking **which wrapper can ACT** (quince#255's rule — all four wrappers are
committed, so a presence test cannot tell two seats apart), the helper **fails closed** like
`bin/git-coder` so a refusal emits no credential rather than a blank password, no usable credential is
a **refusal** rather than a note with a bootstrap carve-out, and an existing helper is **not
overwritten** when it differs — naming its shape, never its value, plus the command that clears it.
**The decision moved above the dry-run exit**, which is beyond the ruling and flagged as such: it
mutates nothing, it refuses before the box is touched as the role guard already does, and it is what
makes all three behaviours observable without provisioning the host the suite runs on. `provision-guard-test`
11 → 20, and **13/7 against `main`** — the two new assertions that pass there are the negative one and
the control, which is the shape that says a suite measures the defect rather than the weather. **Two
self-inflicted bugs, both found by running:** `die` was defined BELOW its first use, so the new refusal
exited **127 with no message** — quince#224's exact shape, in the code written to stop silent failures
— and the suite's credential overrides meant the REAL `gh-coder` correctly could not mint, so every
role-guard row began refusing for the layer's reason instead of its own.
([quince#236](https://github.com/novkostya/quince/issues/236),
[quince#283](https://github.com/novkostya/quince/pull/283),
[quince#255](https://github.com/novkostya/quince/issues/255),
[quince#224](https://github.com/novkostya/quince/issues/224))
