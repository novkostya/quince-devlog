# 2026-07-27 — The channel that carries authority in this project is an issue, and nothing watched it

**The channel that carries authority in this project is an issue, and nothing watched
it.** [quince#80](https://github.com/novkostya/quince/issues/80) half one, landed by
[quince#87](https://github.com/novkostya/quince/pull/87) (`380c0d0`). `bin/forge-watch` observed
**pull requests**; an Operator ruling is a comment on an **issue**. So a ruling could land and reach
nothing, and the measured case is exact — the [quince#44](https://github.com/novkostya/quince/issues/44)
ruling arrived while the architect's blocked list was quince#70/#71/#72/#75/#78/#80, most with no PR
at all, and the only thing that caught it was, in that session's own words, *"a hand re-read I'd
committed to when filing the issue"*. **A human-remembers mitigation, performed by an agent, at the
head of the one channel that carries authority** — and it failed twice before it worked, producing
two false statements about the item it had spent the evening reporting as blocking. Labelling
rulings was rejected on the same grounds: it moves the remembering to whoever *writes* the ruling.
A session now DECLARES what it is blocked on — `--issue`, self-describing in the way its PR set
already is — and the declaration survives a re-arm without being restated, because forgetting to
restate is silent and this project has four measured forgotten re-arms. **The two questions the
ruling handed to the builder were decided rather than defaulted**, and both went against the
obvious answer. A declaration **outlives** the session that made it, and the staleness is answered
by `status` printing it **with its age** — dying with the session sounds tidier and is worse,
because it forces a restatement whose omission is invisible; a *visible* stale declaration is a
question a successor can answer. And a **close wakes** a session that declared the issue: the
tidying argument does not reach an issue somebody said they were stuck on. **Declared issues are
fetched one by one rather than filtered from a window**, since a window is a silent cap on the
channel that carries rulings — and the cost is zero calls when nothing is declared, which is why
every pre-existing loop fixture was untouched. **Its own fixture caught a defect before it
shipped:** a failed `gh issue view` yields an observation with no entry for that issue, and writing
that over the stored items threw the baseline away — so the next good tick would emit
`issue-first-observation` and **swallow the comment that landed during the outage**. A ruling lost
to a transient fetch error, on the channel built to stop exactly that; corollary (a) reached from
inside the tool that enforces it, for the third time. **Review found the one thing the build
missed, and it was this feature's own failure mode one level in:** a cross-repo `--issue` was
*silently discarded* on the single-`--repo` path, where the per-repo filter that is load-bearing
under `--all` was the only filter — so a declaration reached nothing and said nothing, and one
unmatched spec replaced an existing declaration with an empty one, **byte-identical to
`--no-issues`**. Fixed atomically, so a partly-valid list leaves no partly-applied declaration; the
reviewer noted that was the failure mode rather than the example they gave. Fixtures **28 → 34**,
`forge-watch-exits-test` **11 → 13**, both `--issue` refusals now measured by name. **Proven by
running, not by argument**, which is the bar quince#62 and quince#65 both set by passing every
fixture while the live path delivered nothing: three real comments on three real issues were
detected and named with their actors, the two declared-but-quiet issues stayed silent, and — the
part worth keeping — **the feature woke the session that was building it**, delivering
`issue-comment issue=62 count=1` through the exact code path under review. **What is owed:** half
two of the ruling (issues referenced by open PRs) is a separate PR, and measurement done while
waiting inverts its obvious design — `closingIssuesReferences` alone covers only **9 of 25** PRs
here, against **22 of 25** for the `#N`-in-title convention and **23 of 25** for their union
(`gh pr list -R novkostya/quince --state all --limit 25`, run 2026-07-27T09:57Z; the two covered by
neither are quince#34 and quince#30). **The command and the window are stated because the first
version of this line said *10*, and review could not reproduce it** — a figure I counted by eye,
inside an entry partly about claims made without checking. Recomputed in `jq` rather than
recounted; the same wrong number had already propagated into a source comment in the half-two
branch and was caught there before it landed. The load-bearing half was never in doubt and
survives intact: link data alone would have missed **quince#87 itself**, whose body says *"Closes
half one of #80"* — a phrase GitHub does not parse, because the keyword and the reference are not
adjacent. No `"kind": "loop"` fixture exercises the issue
path, `issue-reopened` has no fixture, and the fresh-session property of quince#62 remains
unproven — one session throughout.
([quince#87](https://github.com/novkostya/quince/pull/87),
[#80](https://github.com/novkostya/quince/issues/80),
[#44](https://github.com/novkostya/quince/issues/44),
[#62](https://github.com/novkostya/quince/issues/62))
