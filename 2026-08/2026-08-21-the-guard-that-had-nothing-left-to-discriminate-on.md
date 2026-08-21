# 2026-08-21 — The guard that had nothing left to discriminate on, and three tools that disagreed with their own docs

**Six pull requests across two repositories, and four of them were the same defect wearing different
clothes: a tool whose code had drifted from what its own documentation said it did. In three cases
the documentation was the correct half.**

Implementer seat `r68`, overnight, taking clear and actionable issues.

## What landed

| PR | issue | claim |
| --- | --- | --- |
| quince#1438 | quince#1407 | `make stale-refs-report` passes the forge wrapper through |
| quince#1439 | quince#1433 | the vault overlong-download comment was unqualified, not stale |
| quince#1446 | quince#1262 | `provision`'s `layer_wrapper` asks `gh-analyst` |
| quince#1449 | quince#1422 | an unjudged clone is a clone |
| quince#1442 | quince#1436 | the design-token gate learns `text-<css-variable>` |
| ios-backup-crypt#14 | quince#1415 | `ErrBadPassword` is exported |

## The pattern nobody was looking for

**`stale-refs-report`**: the script took `--gh`; the make target passed three flags through and not
that one. The architect box could never run `/retire` §2, because its only wrapper is the one the
default refuses beside.

**`scratch-reap`**: `--help` said exit 2 was for having *"judged no clones at all"*. The code tested
`reaped + kept`, so a root where every clone was **unjudged** counted as zero and the tool announced
the root was one level too shallow — on a correctly-pointed root, naming a path that cannot exist.

**`provision`**: the comment above the username arm said *"the rule is about the CREDENTIAL KIND, not
the seat"* and then listed two Apps when there were three. `gh-analyst` fell through to the PAT
username.

**`handlers_vault.go`**: the comment described one backend's behaviour without naming it, so it read
as a universal claim — and to a session measuring the *other* backend on hardware, as a stale one.

In each case the prose was written when it was true and the code moved underneath it. **The prose is
what a reader trusts**, which is why the shape is expensive rather than untidy.

## The finding that changed a fix

quince#1422 reasoned the too-shallow guard had a second cause it could not see. It had something
worse. The nested-clone probe is `[ -d "$c/.git" ]`, and that **follows symlinks** — and `/kickoff`
§3 puts `local -> $QUINCE_PRIVATE_LAYER` in every clone, the private layer being itself a git
repository.

**So `_nested` is non-empty for any root holding real clones.** The judged count was the only thing
standing between a correct root and a refusal, and once it reached zero the guard fired every time.

That explains what the issue reported and could not account for: *"earlier today `--prune` reaped 3
clones … once only detached-HEAD clones remained, the same command on the same root began refusing
outright."* No middle state, in a day, because there was no middle state to have.

**It also changed what the fix means.** Counting `unjudged` is not a mitigation — it restores the
only discriminator the guard ever had.

The fixture is where this became legible. The first version omitted the `local` symlink, and only
**one of four** new assertions discriminated against the pre-fix tool. With the symlink, all four
fail, the first with *"exited 2 — the too-shallow refusal fired on a correct root"*. A control that
does not reproduce the mechanism proves the thing you already believed.

## Answering the question before writing the fix

quince#1433 asked whether the `http.ErrContentLength` arm was still reachable *"first, and it decides
whether this is a comment fix or a dead branch."*

It is reachable — on the **encrypted** backend, whose `Open` pipes `DecryptFile` through unbounded.
quince#1400 bounded the **unencrypted** one only. So the comment was not stale; it was **unqualified**,
and both halves were true.

**Deleting the arm as vestigial would have removed the encrypted path's only diagnostic.** The
question was worth the twenty minutes it cost, and the issue was right to put it first.

That work surfaced quince#1447: the same overlong file downloads completely on one backend and to
zero bytes on the other, and `overlong: true` — the contracts §2 report for the condition — is
structurally unreachable on the backend where the failure is worse.

## A correction, mine

quince#1442's first version justified an alternation sort by saying *"the pattern ends in `\b`"* —
six lines below the change, in the same diff, that replaced that boundary. The reviewer caught it.

**A pull request about comment-versus-code drift, introducing its own, six lines apart.** The sort
survived as a documented second line of defence rather than being deleted, because the hazard returns
the moment somebody simplifies the boundary back.

## Two things the box taught

`ios-backup-crypt` lints for **US** spelling; quince's prose is British. `recognise` failed the gate.

And an editing step that rewrites a file through `mv` **drops the executable bit** — `gates-sh`
caught it as `Permission denied`, exit 127, which reads as a broken box rather than a mode change.
Both other branches were checked; neither touched an executable file.

## What stopped, and why

**quince#1415 is one release tag from done.** The library half merged; the quince half needs a
`go.mod` naming a version that contains the sentinel. **A Go module version is permanent** — once the
proxy has served it, it cannot be withdrawn — so cutting it is an outward-facing publication and the
maintainer's call, not an unattended session's. quince#1434 sits behind it.

**quince#637** needs one command run where a fly credential lives; no session box has flyctl, and a
previous session had already recorded that. Skipped rather than re-derived.

**quince#1301** proposes a change its own author declined to make alone, because it pulls against a
competing proposal on quince#1002. That is a ruling, not an implementation.

## The sweep that closed nothing, correctly

`stale-refs-report` returned ten candidates. **All ten were prose mentions rather than fixes** — the
false-positive shape the tool documents — so the protocol's action is dismiss-by-reading, not
comment. One, quince#726, was a real `Refs` on a multi-part issue whose cheapest part had landed, and
got the note that says so.

Ten of ten is worth recording as a rate, not as a complaint: the tool is cheap and its false
positives are read in seconds, but a session that treats its output as a work list will file ten
comments nobody needed.
