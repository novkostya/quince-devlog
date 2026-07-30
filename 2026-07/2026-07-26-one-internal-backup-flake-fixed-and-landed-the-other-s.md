# 2026-07-26 — One `internal/backup` flake fixed and landed; the other's category fix was found INCOMPLETE in review, by a reproduction the implementer could not get — and the load that…

**One `internal/backup` flake fixed and landed; the other's category fix was found
INCOMPLETE in review, by a reproduction the implementer could not get — and the load that
reproduces them all turned up two findings that are not flakes.**
[quince#9](https://github.com/novkostya/quince/issues/9) is done and merged
([quince#36](https://github.com/novkostya/quince/pull/36)): `TestStorySingleFlight` leaves a second
device's job running, and **waiting for that job would not have closed it** — `run()` emits the
terminal row, THEN discards `working/`, and only frees the per-UDID slot on its way out, so
terminal state is not the quiescence signal. The file already half-knew this
(`startWhenReleased`'s note about "the brief single-flight window between a job's terminal row and
the release of its per-UDID slot"), so the fix went into the harness — drain the engine, fail
loudly if it will not quiesce — closing the class rather than the instance. Reproduced at
`-count 50` first attempt; green at 50, at 100 under contention. Review caught it working under
fire: two tests died mid-story with jobs live and **no run produced `directory not empty`**.
[quince#31](https://github.com/novkostya/quince/issues/31) took two passes. The implementer could
not reproduce it (the CI load profile reproduced exactly — `deviceops` 34 s, `httpapi` 17 s — but
the package finished in 9 s and the named test passed 20/20 at 3× oversubscription), shipped a
category fix — waits measure a **no-progress window** rather than a wall clock — and declared in
the PR that the mechanism was unconfirmed. **The architect then reproduced the original failure at
that head, under load**: `no progress for 10.001s … phase=waiting_for_passcode`. The window is
stronger than a budget only in phases that emit progress signals; `waiting_for_passcode` emits
none by design, so there it degenerated back into the very budget being removed. The second pass
mirrors the engine's own rule instead of inventing one — `sampler.sample` already grants grace
"before the FIRST sign of life (a re-exec / process startup can take longer than a short timeout),
or while paused for the passcode" — so the harness grants it in the same four phases and still
guards `receiving`, the only phase where stillness is diagnostic
([quince#37](https://github.com/novkostya/quince/pull/37), merged `eb0150f`).
**The process is the story:** the PR declared its own weakest link, the review aimed at exactly
that link and broke it, and the result is better than either party had alone. **Two findings that
are not flakes**, both filed rather than folded in, because the product is frozen and the branch
was test-only: [quince#35](https://github.com/novkostya/quince/issues/35) — `CancelJob` cancels the
job context, `cmd.Start()` then fails with `context canceled`, and `supervise` returns
`outcomeProcErr` **without consulting `killReason`**, so a user who presses Cancel is told the
backup *failed*, quoting an internal context; the engine checks kill-reason-first in both
`awaitDevice` and `runToolLoop`, and this one path skips it. The **architect's** ruling on quince#35
(2026-07-26 10:46:25Z — rulings post under the `novkostya` login, so the role is named here
rather than inferred) confirmed it against source, found a **second** call site the report
missed (`superviseGatedSeed`, the common path for a cold backup since qn.6b), and scheduled it
to stay filed while the freeze holds and go early once it lifts. **The Operator then ruled it
fixable during the freeze** ([#35 comment](https://github.com/novkostya/quince/issues/35#issuecomment-5084066861),
2026-07-26 15:09:53Z): a cancel reported as a failure corrupts the soak's own record, so an
instrument that miscounts failures during the measurement period damages the very thing the
freeze protects — **a freeze concern rather than an exception to it**, product code by explicit
authorisation, with the freeze otherwise standing, the four owed items still open, and the work
sequenced after the process rungs (quince#43, quince#41/quince#44, quince#45). That reasoning
was the authorisation for this whole day's work and it reached the session before it reached
the forge; it is recorded here only now that it can be cited, which is the standard this entry
set for itself. And
[quince#38](https://github.com/novkostya/quince/issues/38) —
a **third** instance of quince#9's shape: `succeed()` writes the terminal row and calls `AnnounceBackup`
*after*, so a test reading the announce at terminal loses the race; measured pre-existing (`main`
3/60 under load, the branch 1/20, the same rate). Three tests now caught assuming the terminal row
means the work is finished — a pattern in the engine's shape, not three coincidences.
**Ordering, discharged on the record:** quince#9's 2026-07-25 ruling reserved it as the first
post-freeze item; the Operator confirmed on quince#9 at 11:16:25Z that today's `/kickoff` was his
instruction and deliberately discharges that reservation, with the four unfreeze items
([quince#32](https://github.com/novkostya/quince/issues/32),
[quince#33](https://github.com/novkostya/quince/issues/33), `pr.6`,
[devlog#4](https://github.com/novkostya/quince-devlog/issues/4)) still open and still gating. The
implementer declined to cure the gap by restating the instruction itself — a bot repeating an
instruction is not a record of it being given — which is the state-honesty rule applied one step
further than the protocol asked. **The privacy gate failed the same way here as in the docs pass
above**, from the opposite end of the project: neither the runner nor the arch box holds the
pattern list, so `make privacy-check` exits 0 having grepped nothing. quince#36's sweep was
finally run from the private-layer host at approval, and quince#37's at its final head before
landing — both clean, zero findings. Two sessions independently
hitting the same wall on the same day is what moved it from a footnote to filed work
([quince#41](https://github.com/novkostya/quince/issues/41),
[quince#44](https://github.com/novkostya/quince/issues/44)). **Also filed from this cycle:**
[devlog#15](https://github.com/novkostya/quince-devlog/issues/15) — merging a parent PR
auto-closes its stacked children and reopening is refused twice, which nearly cost quince#37's review
thread; and [quince#43](https://github.com/novkostya/quince/issues/43) — the watch loop cannot see
a push, green checks after a fix, a comment, an unchanged verdict, or a mergeability transition
caused by someone else's merge, which is why both PRs sat unmergeable with neither author nor
reviewer told. ([quince#36](https://github.com/novkostya/quince/pull/36),
[quince#37](https://github.com/novkostya/quince/pull/37),
[quince#35](https://github.com/novkostya/quince/issues/35),
[quince#38](https://github.com/novkostya/quince/issues/38))
