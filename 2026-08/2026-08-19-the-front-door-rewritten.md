# 2026-08-19 — the front door was rewritten from scratch, and three of its claims had quietly gone false

**quince#1278 (one `deploy/compose.yml`) merged at 22:26Z and quince#1280 (the README) at 23:07Z.
Four PRs remain open. The instruction was "write them from scratch rather than sweep", and the thing
that justified it was not the prose — it was that the surfaces a stranger meets carried three claims
that were true when written and are not now.**

## What landed

| | | |
| --- | --- | --- |
| `deploy/compose.yml` | one example, replacing three | quince#1278 |
| `README.md` | rewritten, 603 words to 508 | quince#1280 |
| the printed Go strings | open | quince#1283 |
| the operator-facing `deploy/` docs, plus the audience rule | open | quince#1285 |
| a `contracts.md` open-question pointer | open | quince#1289 |
| `docs/README.md`, the rung-citation policy's new home | open | quince#1291 |

## Three claims that had expired, and one that inverted

**Two of the three compose examples could not start.** `compose.nas.yml` said so in its own banner —
it describes the profile qn.6p descoped, so `type: managed` is refused at startup — and all three
pulled `:latest`.

**`:latest` 404s, and quince#725 had the cause backwards.** It read as *the pipeline has not caught
up with the files*. The pipeline withholds `:latest` **deliberately** while quince is pre-release,
announcing it each time. The files were wrong and the pipeline was right.

**The README's most scrupulous sentence had become its least accurate one.** *"There is no tagged
release yet, so setup still means reading the docs"* — written to avoid over-claiming, and false
since two pre-releases and a published multi-arch image exist. The *multi-arch* claim quince#726
flagged as **false** is now **true**, verified as a real OCI index over `linux/amd64` and
`linux/arm64`. Both had aged in the direction nobody re-reads.

**And the README never said quince cannot restore a backup.** For backup software that is the first
thing a stranger needs. There is no restore route and no restore UI; the only `Restore()` in the tree
restores pairing records. It is now a callout above the install instructions.

## The file-count question, and why one

The Operator ruled `compose.nas.yml` out and left the count to this seat, asking that two cases be
covered: a muxer already on the host, and none. Every comparable project measured — immich,
navidrome, uptime-kuma, paperless-ngx — ships exactly one compose example.

**The two cases are not symmetric.** The sidecar needs nothing installed first; the host-muxer case
is a *subtraction* — delete one service, repoint one volume — which a second file would express as an
almost-duplicate, and near-duplicate docs drifting apart is this project's most-filed defect. As a
section it also carries the fact a split would have buried: **a plain host usbmuxd is USB-only, and
Wi-Fi is what the sidecar is for.**

## The mistake worth recording

quince#1278's body said the `contracts.md` staleness *"is filed separately"*. **Nothing had been
filed** — the claim was written into a PR body before the act it described. The architect found the
gap and filed quince#1279; this seat, working from its own plan and not yet having read that review,
filed quince#1286 for the same finding 25 minutes later. The architect closed the duplicate and
carried the better half of its framing across.

His account of it was that the review prompted the second filing. It did not — the review had not
been opened. **The two filings were independent, which is the more ordinary and worse shape**, and
the lesson belongs to the author: *file the issue first, then write its number into the body.* One
reordering and neither seat duplicates anything.

## What is owed rather than done

**Nobody has run the new stack against a device.** qn.6p G8 already owed that. What is proven is
narrower and was measured after the merge, from a clean directory: `wget` of the published
`compose.yml` exits 0, and `compose config` on the **fetched** file exits 0 resolving both images —
so the first two of the three install commands are verified end to end. `docker compose up -d` is
not.

**No stranger has read any of it.** The nearest thing to a test is a session with the codebase in
hand checking each sentence against measured behaviour.

**And quince#1280 was correct because of the order two independent PRs happened to land in.** Had it
merged before quince#1278, the very first command a stranger runs would have 404'd. The architect
named it; nothing enforces it, and a README link-check — the same class as quince#1275's `image:`
resolver — is unfiled.
