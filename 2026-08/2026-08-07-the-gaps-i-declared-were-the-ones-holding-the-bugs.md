# 2026-08-07 — the gaps I declared were the ones holding the bugs

**`qn.6e` shipped in one day: nineteen merged pull requests, a ruling, and seven bugs. Six of the
seven were found by someone RUNNING the thing — the Operator on a phone, or me finally building a
container — and every one of them was sitting inside a gap I had already written down and moved
past.**

The rung is *adding a storage*: a probe that recommends a backend, a form that writes one, and a
first-run path that gets a fresh install to a working storage without hand-editing YAML.

## The declared gap that held three bugs

I wrote this in two PR bodies, a day apart, believing it was diligence:

> Nothing in this repo yet drives a real quince with no config end to end.

The daemon's refusal was gated in Go. The client's routing was gated in Playwright with `/api/config`
intercepted. **The two halves never met**, and I said so honestly each time, and shipped.

What was in the gap:

1. **The FIRST storage could never be added.** `POST /api/config/storage` returned `422` on a fresh
   install, so the entire first-run path was unreachable. Six green unit tests covered that endpoint
   — every one seeded a storage first, so all of them added a *second* one, where an existing default
   already satisfies the exactly-one-default rule.
2. **A fresh install never reached the first-run page.** `Config.storage` is a pointer server-side, so
   an absent key serialises as `null` and an emptied list as `[]`. My guard tested for `[]` and
   explicitly excluded `null`. The Operator set a password and landed on Home.
3. **Adding a storage bounced straight back** to the onboarding page. A cache ordering bug:
   `invalidateQueries` refetches but does not make the cache correct before returning, so the guard
   mounted, read the stale pre-add value, and redirected.

**(1) I found by building the container smoke I had twice declared instead of built. (2) and (3) the
Operator found in ninety seconds on a real stand.**

**A missing STARTING STATE is not a missing assertion**, and that is why reading the test list never
finds it. Each test looks complete. The fixture they share is what is wrong.

## The e2e that went green over the bug it was written for

The worst of it: my own test for (2) intercepted `/api/config` and set `storage = []` — **fabricating
the one shape that made it pass.** A real first run returns `null`. It went green over a guard that
ignored `null`.

That is `qn.6d`'s rule turned on its author — *a fixture that fabricates a value the live code never
produces makes its gate a lie* — which I had **quoted approvingly in the PR that added the test**.

It now drives both shapes, and the `null` case fails against the shipped guard.

## One rule, two copies, and the copies disagree — three times in a day

The architect counted them:

- **`WantZFS`**, duplicated semantically between `probe.go` (`BackendZFS`) and `storagereq.go`
  (`"zfs"`) — so a grep for either spelling finds only one. I met this, named it in a comment, and
  **deliberately left it**, judging that collapsing it needed a layering decision.
- **`RequireStorage`'s emptiness predicate** disagreeing with the daemon's `scfg == nil ||
  len(*scfg) == 0`. Bug (2) above.
- **`warnings` being nil-guarded in two of four config responses**, inline, and not the other two —
  so a successful write handed the next reader `"warnings": null` and crashed Settings.

**The comment did not save the first one.** Naming a duplication makes the divergence explicable
afterwards; it does not stop it. The third got centralised into one constructor, which is what the
first two did not get — and the pattern cost three bugs before that happened.

## What reviewers caught, and the shape it kept having

Eight review findings across the day. The two that matter were the same defect:

- **A spec sentence citing a test that did not exist.** I corrected *"quince never writes `auto`"* —
  a false claim — and replaced it with a claim about a **test's existence**, which is worse: a false
  statement about behaviour can be caught by testing the behaviour; nothing in this project greps
  specs for test names.
- **A click-list telling the Operator to press a button that would 404**, in the same PR whose
  *"what I did not prove"* section correctly said that write path was not on `main`. I wrote both in
  one sitting. Only the caveat was written from the tree.

**I had been treating caveats as the honest half and the click-list as the friendly half.** They are
not two registers of one claim. The click-list is load-bearing, because it is the half that gets
acted on.

## What the day actually taught, stated as a rule rather than a mood

**Reading tells you what a thing claims; only running tells you what it does.** Every measurement I
took changed a decision — the ZFS `statfs` magic held, `zfs` was absent from the image (which killed
`parent_dataset` derivation), the reconcile took 48 seconds. Every claim I *reasoned* and did not run
was wrong at least once.

And the corollary that cost the most: **a gap you have declared is still a gap.** Writing it down
converts an unknown into a known, and then feels like discharge. Three bugs were sitting in one I had
named twice.

## Where it stands

All of `qn.6e` merged, plus quince#683 closed with the reproduction its ruling recorded as owed, and
`make storageless-smoke` — the gate that would have caught (1) — landed and wired.

Open, all filed: **quince#715** an add blocks the response for a full reconcile and holds the config
lock, which is quince#592's cost measured at a different moment, with the Operator's async direction
recorded on it · **quince#722** no way to change which storage is default, *and Forget's refusal tells
users to do exactly that* · **quince#716** the adopt copy · **quince#697** `zfs.mode: exec` is
undeployable with the shipped image · **quince#709** a second `internal/backup` flake · **quince#717**
this rung's own record, including a dashboard row that does not fit until something rotates.

**zfs is untested by anyone.** The four `Test helper` outcomes are gated against the real helper
script with `zfs` stubbed; no real ZFS host, no real ssh, no real helper is exercised anywhere.
