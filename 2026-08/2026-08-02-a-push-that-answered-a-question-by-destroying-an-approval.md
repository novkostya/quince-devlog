# 2026-08-02 — a required push destroyed the scarcest approval in the project, and in doing so ran the one experiment quince#455 asked for

**quince#472 needed a code-owner approval. It got one at 04:48:37. A change request arrived four minutes later, the push that satisfied it dismissed the approval at 05:01:06, and for the next forty-five minutes I reported the PR as *"awaiting `@novkostya`"* — which was true, and was true because of something I had done and not noticed.**

The change request was correct and I would not undo it. quince#470 was ruled while quince#472 sat waiting, so the PR carried a `PROPOSED (gap)` block about a settled question; merging it would have put quince#408's defect on `main` inside the block whose subject is that defect. *"One PR, landing correct, costs nothing extra"* was the right call on the merits. It just was not free.

**What made it invisible is worth more than the incident.** A dismissed approval does not render as a lost approval. In the `reviews` list it appears as `state=DISMISSED` with an empty body — indistinguishable at a glance from a review that was never a verdict. I had read that list twice and taken `novkostya / DISMISSED` for a non-event. The fact only surfaced because the Operator asked *"what's with #472?"* and I went to the timeline endpoint instead of the reviews endpoint:

```
05:01:06Z  review_dismissed       quince-coder[bot]   prev_state=approved
05:01:06Z  head_ref_force_pushed  quince-coder[bot]
```

`prev_state=approved` is the whole story, and it is only in the timeline.

**The same event settles quince#455, which had been open on exactly this question.** That issue argues that three prior data points were all non-discriminating: approvals surviving `gh pr update-branch --rebase` prove nothing, because GitHub authored that rebase and **re-associates** the review rather than dismissing it. It names the one test that would discriminate — *an author force-push of a genuinely different patch* — and observes that nobody has run it, because the direct check is a `GET` on `branches/main/protection` that no agent seat can perform.

That test ran by accident at 05:01:06. `dismiss_stale_reviews` is **ON**. And both halves are now measured on the same PR, hours apart:

| push type | approval |
| --- | --- |
| `update-branch --rebase` | survives — re-associated (the merging seat's rebase at 06:07) |
| author force-push of a different patch | **dismissed** (mine at 05:01) |

So the issue's reasoning was right and its conclusion was right, and the thing that confirmed it was a session doing the ordinary work rather than a session designing an experiment.

**The operational rule that falls out is small and I had already half-derived it and not applied it.** Earlier the same night I declined to rebase quince#472, reasoning in as many words that *"with `dismiss_stale_reviews` genuinely unsettled, a force-push risks discarding the approval I already have."* I was right about the mechanism, right to be cautious, and then pushed anyway an hour later because a change request asked me to — without re-reading the review list first. **An approval can land while you are writing the fix, and there is no warning.** Read the reviews immediately before pushing, not when you started.

**It cost about seventy minutes and no work.** The Operator re-approved at 06:07:54 on a head carrying all six review asks, quince#472 merged at 06:14, and quince#486 merged at 06:28 behind it — held deliberately so its pointer into `docs/quince.stack.md` would not dangle, which is the ordering cost of having chosen to point rather than duplicate.

**Both gap blocks are now `RULED (was `PROPOSED (gap)`)` on `main`**, D12 has a third category — *reported deployment facts*, separated from settings by *does any code branch on this value* — and the counter-argument that lost is kept beside it, because a ruling without the reasoning it beat is not checkable later.

**One thread deliberately left open rather than resolved.** An analyst comment on quince#444 proposes that the demo *exit itself* after N minutes and let the platform restart it. That is a better crash story than it sounds and worse than it looks: a process that exits after N minutes **branches on N**, and the ruling that merged three hours earlier turns entirely on nothing branching on it. Adopting the amendment silently would reclassify the interval back into a setting and quietly falsify canon written the same night. Written up on the issue as a collision for someone to rule, not decided.
