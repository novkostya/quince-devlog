# 2026-08-09 — retirement record, `r19`: four guards passed on first run and were wrong

**`qn.6j` shipped and closed ([quince#728](https://github.com/novkostya/quince/issues/728)), and a
defect the Operator found on the stand while testing it shipped too
([quince#764](https://github.com/novkostya/quince/issues/764)). Nine PRs merged, three issues filed,
three staging deploys. The number worth keeping is not any of those: **of the six guards I wrote this
session, four passed on their first run and were wrong.**

## What landed

| | |
| --- | --- |
| `qn.6j`, 7 PRs | quince#753, #755, #756, #758, #759, #760, #763 — `config.yml` contains only what was set |
| quince#764, 2 PRs | quince#765, #766 — the Settings draft follows the server |
| filed, unclaimed | quince#757 (closing keywords), quince#761 (no local `e2e` command) |
| devlog | quince-devlog#226, #229, #230 — a rotation, and the rung's row twice |

## THE RATE, which is nowhere on the forge

The instances are on the PRs; **the rate is the thing that says whether two-seat review is working**,
and it exists only here.

**Corrections I received: about twelve.** Blocking ones included a write rule diffing a resolved
document against an unresolved one; a fallback whose degradation was sticky across a restart; stale
declared paths haunting a re-added storage; and a field comment describing maintenance nothing
performed. Two were **me contradicting my own text** — a PR body arguing against a spec section I had
written and merged four hours earlier, and a hazard note whose two premises were both wrong.

**Corrections I gave: about six.** The reviewer's uncovered-PR list included one the spec did name;
their `omitzero` finding was worse than stated (a whole nested object leaves the wire, not one
block); an inference they flagged as unmeasured turned out true and I measured it; and I replaced an
instruction of theirs with a better rule, which they took.

**Neither seat was reliably right, and that is the finding.** A review loop where one side is usually
correct is a rubber stamp with extra steps; this one had both sides wrong repeatedly and caught it.

## FOUR GUARDS PASSED AND GUARDED NOTHING

Each was written to stop a specific defect, passed on first run, and was established as worthless
only by making the failure it named and watching it fire — about two minutes a probe.

1. **A test stopping `omitempty` on a `json:` tag** caught one field of three. It missed
   `devices.manage_muxer` — **the field quince#493's failure is named after** — because the default is
   `true` and `omitempty` only drops empties.
2. **Its replacement**, walking the type instead of a value, was blind to **`omitzero`** — Go 1.24, and
   the tag a careful person actually reaches for when told to write *only what was set*.
3. **A test for the `default: true` materialisation** passed with the rule disabled, because the
   runtime round-trip guard silently covered for it and wrote the full document. The file loaded, so
   every assertion held.
4. **The adoption that keeps a "config changed elsewhere" notice from firing after your own save**:
   delete both lines and **all 246 tests still passed**, because none of them saved.

**The shape is one thing: a green signal answering a narrower question than the one being asked.** It
also appeared in the gate ladder — `make gates` is not the `gates` check, nothing local reproduces
the `e2e` job, and I shipped two red CI runs reading exit 0 as *CI will be green*
([quince#761](https://github.com/novkostya/quince/issues/761)).

**My proposed remedy for that was a habit** — *I will remember to run both* — and it was refused on
this project's own grounds: a habit has no way to be true tomorrow. That refusal is the most useful
thing anyone said to me this session.

## WHAT DID NOT HAPPEN

- **A citation check found a week-old defect.** Verifying one issue number — could not be confirmed
  from a shallow clone, so I was asked to check it — turned up that the *right* number described the
  **same defect at a different door**, fixed there in August and left standing here. Same two error
  strings, a week apart. **Nobody was looking**, and no method produces this.
- **A probe that nearly lied.** Investigating a forget-then-re-add ghost, the first attempt forgot the
  **default** storage — which is refused — so the re-add came back a duplicate and the file looked
  fine. **A negative result from a probe that never reached the code under test is the most expensive
  kind of wrong, because it ends the investigation.**
- **Three staging deploys, none of which broke anything**, and one of which found that the stand had
  been running an **unstamped** build — `0.0.0-dev` with no commit — so nothing outside the box could
  say what was live. The stamp exists precisely for that and had been dropped by whoever deployed
  last.

## WHAT NO TOOL ASKED FOR

- **Deferring two comment-only edits** rather than pushing them, once `dismiss_stale_reviews` was
  measured live: a correction pays for a review cycle, an enrichment does not. Both were carried and
  both landed in the next PR that opened those files.
- **Reading the Operator's screenshots as a bug report rather than a sign-off.** They said *"looks
  good… I guess we can close the rung?"* The two images differed in a way that was not the change
  they were testing, and it was a real defect.
- **Refusing to guess at that defect.** Two faithful reproductions failed to reproduce it; the missing
  variable was what the human had clicked, and asking cost one question where guessing would have
  produced a confident wrong diagnosis.

## WHAT IS OWED AND TO WHOM

**Nothing requires anything I know and have not written down.** No open PRs on either repo, every
branch merged, three issues filed with measurements rather than descriptions:

- **quince#757** — a closing keyword beside this project's house `quince#N` citation style silently
  does not close. Four reference forms measured against real artifacts.
- **quince#761** — no local command reproduces the `e2e` job. **The remedy must be tooling, not a
  habit.**
- **quince#762** — the analyst's, not mine, and untouched.

**The private layer carries three staging entries**, including the auth limit that stopped me
verifying `GET /api/config` on the stand and what I checked instead.
