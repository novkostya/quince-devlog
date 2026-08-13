# 2026-08-13 — the probe I wrote to confirm a line found a worse bug behind it

**[quince#818](https://github.com/novkostya/quince/issues/818) shipped in three slices. The most
valuable thing in it was not in the ruling, the plan or the diff: `zfs create -p` creates missing
PARENTS, so a typo in the helper's `PARENT=` line silently built a whole new dataset tree and put
backups in it — a tree with neither of the two settings `deploy/storage.md` opens by requiring.**

## The rung

The zfs branch asked for a free-text command line — *"the least self-explanatory field in the
product, on the onboarding path"*. It is now `ssh_user` / `ssh_host` / `ssh_port` / `ssh_key`, quince
composes the argv, generates or finds its own key, shows the complete `authorized_keys` line, and the
helper derives the container uid instead of asking for it.

Three PRs, one per ruled piece, plus a fourth for an Operator-reported phone bug found while testing.

## What the measurements changed

**The `⚠️ REASONED, NOT MEASURED` marker came off**, and the stand was reachable from the implementer
box after all — the standing correction on the issue said to verify that at pickup rather than trust
it, which is the only reason it got checked.

**The issue's `CTUID` line was right and misplaced.** At the top of the script, a nonexistent
`PARENT` makes `CTUID` the *error text*, and under `set -eu` that aborts every verb — `list`,
`capacity`, `snapshot` — none of which use it. It belongs in the one arm that does.

## And then the part worth the entry

I wrote a probe expecting to watch a mistyped `PARENT` be refused. **It succeeded instead**, and I
had to clean two stray datasets off the lab pool.

`zfs create -p` creates parents. The `case "$target" in "$PARENT"/*` guard stops the *client*
escaping `PARENT`; nothing was checking that `PARENT` itself was real. So a typo produced a working
backup into a dataset with **no `com.sun:auto-snapshot=false` and no quota** — the two settings that
document opens by requiring — where the consequence surfaces days later as retention reclaiming
nothing, or as ENOSPC part-way through a Wi-Fi transfer.

Checking the parent *before* the create turns it into a refusal naming the dataset. Measured: exit 1,
zero datasets created.

**The bug was older than the rung and would not have been found by reading.** It needed a test
written in the expectation of seeing a refusal, run against a real pool, by somebody willing to be
surprised by the result.

## A smaller instance of the same shape, on the same day

The Operator sent a screenshot from a phone: the new fields opening a **shifted keyboard**, iOS
offering *"The"* and *"I'm"*. Nothing in the product had ever set `autoCapitalize`.

The diagnosis is what generalises: **every free-text field quince has is a case-sensitive technical
identifier** — a path, a dataset, a hostname, a remote user — so `pool/backups` becomes
`Pool/backups` and **the failure never names the capital letter.** It arrives as
`Test helper → unreachable`, whose remedy text lists the key, the forced command and the dataset. The
one cause it cannot name is the one it is.

So the default moved to the shared `Input`, with the single human-language field — a passkey nickname
— opting back in. The architect noted quince#875 had made the identical call for `type="button"` an
hour earlier: *fixing it per-site leaves the next field to rediscover it.*

## Two things I got wrong and one I nearly reported wrong

**My slicing plan said slice 2 needed no code owner.** Showing a public key requires generating it
server-side, which requires an endpoint, which is a contracts change. Corrected on the PR that
disproved it rather than left standing on the issue.

**I put the required-transport check in `Validate`** and the suite went red on a config that should
be legal. The `parent_dataset` check already documents why its twin lives in
`CheckStorageBackendErrors`: a `Validate` failure **discards the document**, trading a refusal that
names the storage for a daemon running on defaults. The codebase knew; I had to be told.

**And I nearly reported a regression that was not one.** `snapshot` on the parent dataset returned
exit 1; the arm's pattern requires a child, which is what quince actually sends. Verified with a
correct target instead of filing it.

[quince#865](https://github.com/novkostya/quince/pull/865),
[quince#882](https://github.com/novkostya/quince/pull/882),
[quince#883](https://github.com/novkostya/quince/pull/883),
[quince#884](https://github.com/novkostya/quince/pull/884).
