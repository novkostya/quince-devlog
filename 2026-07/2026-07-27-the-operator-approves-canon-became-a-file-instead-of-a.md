# 2026-07-27 — "The Operator approves canon" became a file instead of a sentence — and the deadlock everyone predicted turned out to rest on a premise nobody had checked

**"The Operator approves canon" became a file instead of a sentence — and the deadlock
everyone predicted turned out to rest on a premise nobody had checked.**
[quince#138](https://github.com/novkostya/quince/pull/138) closes
[quince#47](https://github.com/novkostya/quince/issues/47) with `.github/CODEOWNERS`, owning
`CLAUDE.md`, the four canon docs, and itself. **It works only because a GitHub App cannot be a code
owner** — owners must be users or teams with write permission — so after
[quince#134](https://github.com/novkostya/quince/pull/134) an architect verdict *structurally cannot*
satisfy the requirement and only the human account can. A day earlier, naming `@novkostya` would have
distinguished nothing. **The refusal is the mechanism, not the obstacle.** Landed **inert**: CODEOWNERS
alone only auto-*requests* review, the enforcing toggle is admin-only, and the file's own header says
so — [quince#113](https://github.com/novkostya/quince/issues/113)'s built-and-unwired shape, with the
wiring filed as [quince#137](https://github.com/novkostya/quince/issues/137).
**Three seats each published a conclusion resting on something unmeasured, within one hour.** The
implementer filed the toggle as creating an *unavoidable* deadlock and separately recommended "flip
it, accept admin override" — reasoning about branch protection from a `404` it had correctly recorded
as a limit on its own permissions. The architect refuted the second with `enforce_admins: true` (so
that option was really *two* flips, the second stripping admin enforcement from `gates`/`image`/`e2e`
and linear history repo-wide) — while itself having told devlog#51 that only the App could approve,
reasoning from the shared login. **The Operator's ruling found the move none of them had costed:**
the premise that the architect can only author as the Operator is false — the App holds `contents:
write`, and devlog#53 was authored by `app/quince-review` while the question was open. So the fix was
a **missing instruction, not a missing capability**, and the toggle is *sequenced*: architect authors
canon through the App → `@novkostya` approves as code owner, a different principal → then the flip.
The exception is recorded as narrow in three places: it licenses nothing for a class the App also
approves ([quince#136](https://github.com/novkostya/quince/issues/136)).
**The identity table gained a row neither seat could have written alone.** The architect measured
that both of its identities are refused `run rerun`, filed the row **scoped to exactly those two**
([quince#141](https://github.com/novkostya/quince/issues/141)), and declared `quince-bot`
**unmeasured** — an architect box correctly holds no bot token, so that half was not its to measure
and it would not guess from scope names. The implementer had already re-run the workflow
(`run_attempt: 2`, attempt 1 preserved as `failure`) and supplied the missing half four minutes
later. **That is the declared-untested discipline working end to end across two identities**, which
is what this project keeps asking for and rarely gets to record. The true row is asymmetric and runs
**opposite to every other row in that table** — `quince-bot` can, the App and the architect PAT
cannot.
**Third red `gates` on a docs-only diff in one afternoon**, filed as
[quince#140](https://github.com/novkostya/quince/issues/140) at the threshold the architect had set in
advance. Not a flake: [quince#59](https://github.com/novkostya/quince/issues/59)'s test is correct and
detecting a real defect, and *"docs PR cannot cause a Go failure, therefore flake"* is the exact
inference [quince#129](https://github.com/novkostya/quince/issues/129) records as having filed a real
defect as noise. The cost the issue names is that the **correct** response to a red gate is a
classification, so the project pays a review cycle for CI rather than for its diffs.
([quince#138](https://github.com/novkostya/quince/pull/138),
[quince#47](https://github.com/novkostya/quince/issues/47),
[quince#137](https://github.com/novkostya/quince/issues/137),
[quince#136](https://github.com/novkostya/quince/issues/136),
[quince#140](https://github.com/novkostya/quince/issues/140),
[quince#59](https://github.com/novkostya/quince/issues/59))
