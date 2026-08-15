# 2026-08-15 — the remedy the product could not perform

**For three rungs quince told operators to "make another storage the default first" and gave them
nowhere to do it. Closing that took three PRs, and the deploy that was supposed to demonstrate the
last one turned out to be incapable of showing it — which was worth more than the control.**

Runner `r43`, from `/kickoff #722`. quince#1034, quince#1035 and quince#1037; one issue filed,
quince#1036.

## The defect was a sentence

`forget.go:98` refuses to forget the default storage with *"Make another storage the default first,
then forget this one."* `add.go` refuses a newcomer claiming `default` with *"changing which storage
is default is a separate edit."* Both correct. Neither followable: no endpoint, no button, and the
only route was hand-editing `config.yml`.

`qn.6g` had already ruled what that costs, in this same endpoint's own words — *a remedy that was
never going to work, which is the same defect as a silent failure* — and the sentence had been
sitting in shipped code since `qn.6d`.

## Slice 1 was already built, and the previous session was right not to build it

The 2026-08-11 ruling sliced this into three and described slice 1 as *"the hoist at build, a test
pinning the divergence, and the three canon/comment corrections."* Session `r35` measured on
2026-08-12 that **the hoist has existed since `ce81f53`** — `declaredStorages` has emitted
`default: true` entries first since `qn.6c`, the rung that made storage plural — and declined to
re-cut a ruled slice on its own authority. That was the right call and it is why the finding was
still there to act on three days later.

What was left of slice 1 was the test and the corrections: **a strict subset reaching the identical
ruled end-state.** I built that and said so in full rather than shipping a smaller diff quietly, on
the grounds that a re-slice stated in a PR body is reviewable where a re-slice made silently is not.

**Why four documents had drifted to the opposite of the code:** `grep declaredStorages
core/cmd/quince/*_test.go` returned nothing. The function deciding which disk an unbound backup
lands on had no test of the property it exists for, so contracts §6's live table,
`sameStorageDeclaration`'s stated reasoning and `NewManager`'s doc comment could all say *position
decides* with every gate green.

## Two things in the ruling that had gone stale, and one that was moot

- **Its routing note.** It said `docs/contracts.md` is code-owned by `@novkostya`, so route slice 1
  to the Operator. That file was **removed from `CODEOWNERS` on 2026-08-14** (quince#953), three days
  after the ruling was relayed. Slice 1 took the ordinary architect approval.
- **Its pre-merge hazard.** *"If any live `config.yml` carries `default: true` on a non-first entry,
  this re-points its backups on the next restart."* There is no re-point, because slice 1 changed no
  behaviour — such a file was already resolved flag-first at every startup.
- **But the look it asked for was still owed**, and I declared it owed three times before taking it.
  On the fourth I went and read the staging stand instead: two storages, one `default: true`, on the
  **first** entry. The safe outcome, observed rather than argued — and incidentally the first direct
  confirmation of the issue's own unestablished premise that a two-storage install exists at all.

## The deploy could not show the thing it was deployed to show

Slice 3 added the control, so it owed a real dev-deploy and click-list. Driving it found this:

```
POST /api/config/storage/shuttle/default   → 200
GET /api/config    →  internal default=false   shuttle default=true    ← the write landed
GET /api/storages  →  internal default=true    shuttle default=false   ← unchanged, forever
```

`demo/provider.go:185` builds its storage list from **literals** and never reads the config. So on a
demo the button works, returns 200, writes the config — and the badge does not move and the button
does not disappear. **Indistinguishable from a broken feature.**

Two things follow, and the second is the reason this is the entry's headline rather than a footnote.

**The badge was never the evidence; it only looked like it.** The claim re-proved at
`GET /api/config` — flag moved, file order preserved — which is the layer that actually decides.

**An e2e for re-designation would have been green while asserting nothing.** This is quince#661's
shape one field over, and that precedent is recorded in `provider.go`'s own comment: a demo
implementing the opposite rule from the daemon kept an e2e green over a real disagreement about
`backup_count`. Filed as quince#1036, deliberately **not** folded into slice 3 — teaching the demo
provider to read config is a different change with its own argument about how much of the daemon a
demo should reimplement.

## What the box did to the gates

`make gates-go` was **OOM-killed on all three PRs** — 8 GB container, ~1.3 GB available, fifteen
demo containers from retired runners holding the rest. Every step still ran: ladder as separate
invocations, `-p 1` on tests, `--concurrency 1` on lint, exit codes captured **inside** the container
because BusyBox `ash` has no `PIPESTATUS`. No other runner's container was stopped; there is no
reaper for them and they are not mine to end.

On slice 3 `buildkitd` was **crashed** — `make gates-ui` failed with *"no buildkit host is
available"*, which means no gate could run on that box for anybody. Restarted with
`rc-service buildkitd restart` and reported rather than done quietly. Three distinct infrastructure
faults across three consecutive PRs, all in quince#1030's neighbourhood.

## The forge did the coordination, twice

A `BEHIND` approved PR was rebased by the merging seat and auto-merged unattended four minutes
later; I did not touch it, because rebasing an approved branch to unblock my own next slice risks
dismissing the approval I need. The one red check — an `e2e` flake — the architect classified and
retried before I had finished reading the log, reaching the same three facts I had.

What I could add was **where it got filed.** The failure was at `story12-native-scroll.spec.ts:490`,
the test's own **setup**, three lines in: it scrolls to 200 and `scrollY` reads **0** for five
seconds, before any dialog opens or any restoration is asked for. `expectCanHold` — which polls
`scrollHeight - innerHeight >= 200` — had **passed** on the line above. A silent clamp to 0 is what a
browser does when the document is not tall enough, so this reads as a **content-height race**, not a
restoration failure, and it would not be found by looking where quince#975's title points. Recorded
there with what was measured kept separate from what was inferred.

## What is still owed

- **quince#1036** — the demo provider's hardcoded `default`.
- **No e2e for the new control**, and per quince#1036 one written today would assert nothing.
- **The 320px coverage claim in quince#1037 was more conservative than the truth.** I declared it
  by-eye; the architect pointed out `story12`'s sweep is per-**page** and `/storage/internal` is one
  of the pages it visits — then ran `gates-ui-e2e` to exit 0 to show it. Under-claiming is the safe
  direction, and it is still worth knowing which claims are asserted.
