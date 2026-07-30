# 2026-07-27 — The reviewer stopped being a person — verdicts now render as `quince-review[bot]` — and the PR that wired it was the first to feel the change

**The reviewer stopped being a person — verdicts now render as `quince-review[bot]` —
and the PR that wired it was the first to feel the change.**
[quince#134](https://github.com/novkostya/quince/pull/134) replaced the shared-login review path
with a GitHub App. `bin/gh-review` mints a per-call installation token and caches nothing;
`preflight` asserts the credential can **MINT**, not merely that a key file exists —
[quince#121](https://github.com/novkostya/quince/issues/121)'s presence-vs-capability lesson turned
on the check written to apply it. `CLAUDE.md` gained a fourth identity row, and `/architect` §1 was
rewritten so identity is asserted with `api /installation/repositories` (**=5**) rather than `api
user`, which an installation token answers `403` to by design. This closes the omission the prior
entry named: [quince#123](https://github.com/novkostya/quince/pull/123)'s table had no App row.
**The review's strongest fact is that the tool refused to let the reviewer use it.** The PR made
`bin/gh-review` the canonical verdict path but shipped **no allowlist entry** for it, so the first
attempt to cast the App verdict was blocked by the harness — found by hitting it, not by reading.
The companion finding: the wrapper's `>1 installations` branch died unconditionally while its own
message named `QUINCE_REVIEW_INSTALLATION_ID` as the remedy — an error advertising a fix the code
could not reach. Both were fixed in review (`87b5898`): the allowlist entry added, the override made
reachable, each crediting the read.
**The App then cast its first real verdict** — approve, rendered as `quince-review[bot]`, on the
very PR that defines it. [quince#130](https://github.com/novkostya/quince/issues/130)'s ruling that
an App approval satisfies branch protection **alone** was exercised for the first time; the merge,
by the Operator (the author's own seat, which a shared login could not have reviewed —
[quince#47](https://github.com/novkostya/quince/issues/47)), confirmed it.
**Two governance questions were raised and not self-resolved:** whether an architect *opening* the
PR crosses "does not implement" — moot, the Operator opened it; and whether the reviewer approving
the canon that defines its own authority is acceptable — the reviewer recommended the Operator cast
it and the Operator directed the App to approve. **Corrections: two findings, both reviewer→author,
both accepted** — the two-seat review did its job on the PR built to make that review a distinct
voice.
([quince#134](https://github.com/novkostya/quince/pull/134),
[quince#47](https://github.com/novkostya/quince/issues/47),
[quince#130](https://github.com/novkostya/quince/issues/130),
[quince#121](https://github.com/novkostya/quince/issues/121),
[quince#123](https://github.com/novkostya/quince/pull/123))
