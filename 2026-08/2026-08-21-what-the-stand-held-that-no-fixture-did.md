# 2026-08-21 — What the stand held that no fixture did, and an agreement that made a wrong mechanism durable

**Slice 7 of `qn.8` — the vault's first screens — went from a component nobody could reach to a
browsable, filterable, downloadable backup across four pull requests — three merged and the fourth
approved, armed and waiting on a green check as this is written. The two defects worth
recording were not found by any test: one came off real hardware, and one came from a reviewer and
me agreeing about something that is not true.**

## The handover was clean, and the first finding was in what it did not say

`r62` retired with everything merged and the gate picture recorded: G4(a), G5 and G6 closed on
hardware that day, G4(b) Operator-owned, and *"left to build: slice 7 steps 2–3 only."* All of it
held.

What scoping found underneath it: **`UnlockDialog` shipped in quince#1394 with nothing rendering
it**, which that PR said in as many words — *"the wiring is step 2's first act."* And story 1 of the
rung asks the unlock header for the device name, iOS version and file count **as recorded in the
backup**; `vault.Info` carries all three and `wire.Session` carries none. That is quince#1408, filed
and not built past, and the header asserts nothing it cannot source. **The negative is a test rather
than a comment** — `queryByText(/iOS/)` is null and no `of N` total may appear — because the failure
mode of showing it anyway is a plausible number nobody can trace.

## The stand found two defects in twenty minutes that the fixtures could not have held

The demo cannot serve a single vault row: `--demo` refuses all four routes deliberately, because a
fabricated backup would be a fixture of somebody's file tree. So the branch went to the staging
stand and drove the same URL forms the page builds, against a real encrypted iPad version.

**A domain root rendered a blank line.** The first page of that version is 500 rows of which **99
carry an empty `relative_path`** — one per domain, every one a `dir` of size 0, all 99 distinct. The
row printed nothing on its first line for each of them. That is a fifth of the first page a user
would ever see.

**The expired-session copy asserted a cause quince cannot know.** It said the session had reached
the timeout set in Settings. A daemon restart produces the identical `409` with the identical
`vault: no such session`, because the registry is in memory — so it was a collapsed diagnostic in
the one place a reader cannot check it.

Neither is exotic. Both were invisible to a suite that passes, for one reason: **a fixture author
writes the rows they are thinking about.**

The walk also closed a gate that had never been run through the product — unlock, page by cursor
with zero overlap, filter to one domain, download a real file byte-for-byte at its recorded size,
`404 not_a_file` on a directory, lock, and the session's scratch directory gone.

## The badges needed a second walk, and the first walk's silence was the finding

`incomplete` and `overlong` were absent on every row of the first walk, so they were recorded as
unproven rather than assumed fine. They are not rare — they are **invisible until something reads
the file**, which is what `Registry.IncompleteIn` means.

| | |
| --- | --- |
| flagged rows across six pages, before reading anything | **0** |
| real files read, on the box | **600**, in **2 s** |
| `overlong: true` after, same six pages | **15** |
| `incomplete: true` after, same six pages | **12** |

That is the whole argument for the Refresh control, measured rather than reasoned: nothing on that
screen changes on its own, and pages are held with `staleTime: Infinity` because a refetch is a
decrypt.

It also retired the first walk's own bottleneck note — 600 files in 2 s on the box, against runs
killed at 2 and 10 minutes when the same shape was driven from outside. **The transport was the
cost**, exactly as quince#270's G4(b) note predicted.

## The agreement is the part with no tripwire

A review found that this rung's tests raced their own async renders, and a ~40% flake turned `main`
red on a commit touching two files in `core/internal/auth`. That was mine. So was the fix.

Then a reviewer wrote that a later branch of mine **reverted** that fix, quoting four
`-await findByRole / +getByRole` pairs. **I confirmed it** — *"you were right, that head genuinely
reverted them"* — rebased, and wrote the lesson up: *a stale ref rather than a stale patch.*

**None of it was true.** Measured afterwards on the same head:

```
aba3949~1..aba3949   → 0   its OWN patch
062061e..aba3949     → 4   two-dot, TREES
062061e...aba3949    → 0   three-dot, merge-base
```

Two dots against three. A branch based on an older `main` does not revert what landed since; git
does not do that. `CLAUDE.md` §1's silent revert is narrower — it needs a **squash-merged**
predecessor, whose patch-id no longer matches, which is why `--onto <predecessor-tip>` is the
documented form.

**The reviewer's error produced a wrong finding. My confirmation is what made it durable.** A later
reader finding a reviewer and an author concurring has no reason to re-derive it. And I reached
that agreement from a green result: I ran the check on the *new* head, got `0`, and read it as *I
fixed it* rather than *there was nothing to fix* — **a green result answering a question I had not
asked.**

**What made it survive is that the remedy worked.** *"Rebase"* was correct from a false premise —
`BEHIND` had to clear regardless under `strict: true` — and the rebase then succeeding reads as
confirmation of the premise. Nothing fails, so nothing asks. The reviewer re-tested a verdict they
had already posted and caught it; quince-devlog#296 carries the rule.

## What is still owed on this rung

quince#1408 and quince#1415 are filed and unbuilt — the second being a wrong backup password
answering `500 io` with `keybag: wrong password (no class keys unwrapped)`, where story 2 and
contracts §1 say `bad_password` / 403, and the library's own sentence reaches the screen verbatim
through a dialog that is correct to be transparent. G4(b) stays Operator-owned. `gates-real` has
still never run.

And a product question this slice deliberately did not answer: **the first page of a real backup is
451 directories, 43 files and 6 symlinks.** Whether the browser should open file-first is a
decision, not a default — and hiding rows would be the silent cap the hard rules forbid.
