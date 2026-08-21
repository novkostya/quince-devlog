# 2026-08-21 — An architect session's retirement: eight findings, four errors, and the one that shipped

**One reviewing seat, ~13 hours, 26 PRs merged across three repositories. Eight findings that changed
a PR, all of them the same class — a comment claiming a property the code does not have. Four times
this seat was wrong, and one of those reached `main`. The ratio is filed because the instances are on
the PRs and the rate is nowhere.**

## What this seat is apparently for

Every finding that changed a PR was the same shape:

| | |
| --- | --- |
| [quince#1375] | `statusForVaultCode` claimed totality in a comment and had two holes |
| [quince#1378] | contracts said two codes live above the seam; the same diff's own new file said three |
| [quince#1380] | the socket's send-time filter justified itself by revocation it could not see |
| [quince#1381] | a comment called the long-file case "silent" one commit before a test proving otherwise |
| [quince#1388] | a comment asserted `latest/` on zfs, from canon corrected that morning |
| [quince#1402] | a dedup kept one copy's header and dropped the other copy's guard |
| [quince#1403] | the push filter claimed revocation reached it; nothing linked the two |

**Seven of eight are a claim about behaviour that the behaviour does not support.** That is worth
naming because it is *not* the same skill as knowing whether something works — and the difference is
what the next section is about.

## The four errors, and why the shipped one shipped

**[quince#1388] — this seat approved a silent truncation into `main`.** The PR said its bounding
"matched the encrypted path". This seat had reviewed [quince#1381] **forty minutes earlier**, and
that PR exists *only* because the encrypted path overruns `Content-Length` — its
`errors.Is(err, http.ErrContentLength)` arm could not execute otherwise. Two claims that cannot both
be true, both approved by the same seat within the hour.

**The cheapest available check was not made**: comparing a PR against the one merged most recently in
the same area.

The other three cost nothing only because something else caught them:

- **nearly merged a red ladder** ([quince#1380]) — a `grep` matched the Makefile's echoed recipe and
  a background wrapper's exit masked `make`'s. Two instruments agreed and both were wrong. Caught by
  re-running with the whole log to a file.
- **instructed an implementer to publish device content** — *"put the measured strings in it"*, where
  the measured strings were the Operator's filenames. The implementer filed byte patterns instead
  ([quince#1405]). An architect telling an implementer to leak is the more dangerous direction.
- **asserted a watch was armed when it was not**, and compounded the arm with `&` twice — the form
  canon forbids in capitals — producing four `orphaned` watchers that report running and wake nobody.

## The number that is not on any PR

**8 findings · 4 errors · 1 shipped**, against the retiring implementer's **~6 self-corrections and 4
of this seat's findings accepted** ([quince-devlog#294]).

Two-seat review found things neither seat would have alone. **The one defect that reached `main` got
there because a reviewer read a comment instead of cross-checking it.**

## What actually found the defects, and it was not review

Every correction that mattered came from deploying and looking:

- the silent truncation — found on hardware an hour after slice 4 merged, behind a green `gates-go`
- the false log line ([quince#1400]) — found by running a *declared* "not re-run on hardware"
- the NFD filename — found by asking the corpus instead of inventing inputs
- two vacuous comparisons — found by an implementer auditing their own evidence

**And [quince#1393] came from the Operator asking why renaming a device should touch a scoped
passkey.** This seat had analysed that collision three times and proposed a discriminator suffix —
all symptom. One question one layer down turned three open threads into a single defect: every
credential presented the same WebAuthn `user.id`.

## The stale-refs sweep, recorded because silence is not distinguishable from not looking

`/retire` §2's sweep returned **15 candidates**. Acted on the four this seat owned: closed
[quince#1375], [quince#1376] and [quince#1393] quoting their merges; left a **sentinel** on
[quince#1379] naming why it stays open — the encrypted path still has no `overlong` field.

**The remaining eleven were read and left for a seat with the context**, rather than commented on to
quiet the tool, which its own guidance forbids. They are #360, #493, #571, #726, #940, #1262, #1314,
#1329, #1338, #1344 and #1389. [quince#1329] is the Operator's archaeology sweep and stays open by
that ruling.

**Running the sweep produced a finding of its own** — [quince#1407]: `make stale-refs-report`
hardcodes `bin/gh-coder`, so the target exits 2 on the architect box. `/retire` §1 warns about
exactly this shape for itself and §2 then prescribes a target with the same defect.

## What is owed

**Five slices of qn.13 authorization work — 7b, 8a, 8b-1, 8b-2, 8c — have never run against a real
scoped credential**, because nothing mints one. Every refusal is unit-tested rather than observed.
Slice 9's enrolment ceremony is the first real exercise, and [quince#1398] is what makes it safe to
run on a device already holding the admin's passkey.

**[quince#1388]'s seek-versus-skip advantage is unmeasured** at the only depth where it would appear.
G6 looks at page one; the claim is about a deep cursor. This seat approved it partly on that argument.

[quince#1375]: https://github.com/novkostya/quince/issues/1375
[quince#1376]: https://github.com/novkostya/quince/issues/1376
[quince#1378]: https://github.com/novkostya/quince/pull/1378
[quince#1379]: https://github.com/novkostya/quince/issues/1379
[quince#1380]: https://github.com/novkostya/quince/pull/1380
[quince#1381]: https://github.com/novkostya/quince/pull/1381
[quince#1388]: https://github.com/novkostya/quince/pull/1388
[quince#1393]: https://github.com/novkostya/quince/issues/1393
[quince#1398]: https://github.com/novkostya/quince/pull/1398
[quince#1400]: https://github.com/novkostya/quince/pull/1400
[quince#1402]: https://github.com/novkostya/quince/pull/1402
[quince#1403]: https://github.com/novkostya/quince/pull/1403
[quince#1405]: https://github.com/novkostya/quince/issues/1405
[quince#1407]: https://github.com/novkostya/quince/issues/1407
[quince#1329]: https://github.com/novkostya/quince/issues/1329
[quince-devlog#294]: https://github.com/novkostya/quince-devlog/issues/294
