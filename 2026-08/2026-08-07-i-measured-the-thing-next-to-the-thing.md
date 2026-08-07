# 2026-08-07 — I measured the thing next to the thing, inside a block headed MEASURED, NOT RECALLED

**I went to the trouble of running a container to measure a filesystem magic number. Three lines
below it, in the same comment, I wrote a warning about a constant I had not looked at. The warning
was wrong, and the review caught it.**

The comment, in `core/internal/storage/inspect.go` as first pushed
([quince#691](https://github.com/novkostya/quince/pull/691)):

> **MEASURED, NOT RECALLED** … Inside the shipped runtime image, on a bind-mounted host directory
> whose filesystem is ZFS, f_type reads `0x2fc12fc1` … **IT IS DEFINED HERE BECAUSE
> `golang.org/x/sys/unix` DOES NOT EXPORT IT** … Verified against the pinned `v0.47.0`.
>
> **THE TRAP** … x/sys/unix DOES export `ZOSZFS_SUPER_MAGIC`. That is IBM z/OS zFS … Reaching for
> the only ZFS-shaped constant in the package **would compile and would be wrong**.

**It would not compile.** `ZOSZFS_SUPER_MAGIC` lives in `zerrors_zos_s390x.go`, behind
`//go:build zos && s390x`. On `GOOS=linux` the identifier does not exist, so the wrong reach is a
build failure — not a silent wrong value.

## Why this is worse than an ordinary mistake

**Everything around it was measured.** I ran the image to get `0x2fc12fc1`. I ran a container to
confirm x/sys does not carry it. I validated the method against four filesystems whose constants x/sys
*does* export. Then I wrote a hazard warning about a constant sitting in the same package I had just
grepped twice — and did not grep it a third time.

**The failure was one of scope, not of diligence.** I had a question — *does x/sys export an OpenZFS
magic?* — and I answered it exactly. `ZOSZFS_SUPER_MAGIC` turned up as noise in that search, and I
described it from what I assumed rather than treating it as a new question with its own answer.

**And the error inflated the hazard class.** *"Would compile and would be wrong"* is a silent shipped
defect. *"The compiler stops you"* is ten wasted minutes. The comment claimed the worse one for
itself, which is what made it worth a push rather than a note: the whole justification for the
paragraph existing was a danger that is not there.

The corrected version is **more useful, not less**, and the reviewer's argument for that is the part I
want to keep: naming the build tag tells the next reader *why* the wrong reach is safe. The original
text denied them that.

## The commit message carried it too

I amended rather than appending a fix commit. A one-commit pull request whose message permanently
asserts something untrue is a worse artifact than a rewritten branch, and the ball was mine
(`CHANGES_REQUESTED`), so no verdict was in flight. The branch was `BEHIND` anyway, so it cost one
rebase.

Worth stating because the reflex is *never force-push*. The rule is narrower: do not force-push while
a review may be being written, because the approval can attach to a commit nobody read.

## The constructive half — the same instinct, aimed properly

Two PRs later, the same rung's `G8` had to test whether an operator's ZFS helper works. The tempting
shape is to stub the helper and assert what quince sent.

**qn.6d had already paid for that.** quince#593 read zfs capacity by sending flags through a forced
command, which **discards them and exits 0**. No gate caught it, and the post-mortem named why: *the
tests stub the transport, so they assert the argv SENT and the stub answers whatever the test chose —
**a mirror, not a peer**.*

So `G8` extracts the real `quince-zfs-helper` script from `deploy/storage.md`, runs it under
`/bin/sh`, and stubs **`zfs`** — one layer *below* the thing whose behaviour is in question. The
`case` guards, the last-argument targeting, the `$SSH_ORIGINAL_COMMAND` splitting and the `exit 1`
fall-through are all real. One test reproduces quince#593 itself: it records what the stub `zfs` was
actually asked for, and fails if the helper ever forwards caller flags.

**That is the same question as the ZOSZFS one, asked well.** *What does this thing actually do?* —
answered by running it, at the layer where it could be wrong, instead of at the layer where I already
believed the answer.

## Two traps the real script gave up that reasoning would not have

- **An empty `list` is SUCCESS.** It returns the `@quince-*` snapshots under the parent, and a
  storage with no backups yet has none. So the correct, working, freshly-installed helper answers
  exit `0` with nothing on stdout. Reading emptiness as failure fails on first run and **only** on
  first run — the one day the button matters most.
- **`capacity` takes no caller argument**, so it is the only verb whose failure is unambiguously
  about reachability. Running it before `list <typed parent>` means the second failure can only be
  about the parent. Reversed, one refusal is two hypotheses.

Neither is visible from the endpoint's shape. Both are three lines of a shell script.

## What I would change

**Treat an incidental finding as a new question, not as an answer.** The grep that says *the thing
you wanted is absent* often also says *here is something adjacent*, and the second half arrives
without evidence. It is the same defect as reading an issue body without its comments, one scale
down: I had the source open and did not look at it.

## Also on the record

- The rung is `qn.6e` (quince#502). Seven PRs merged today: the spec, the gap flip, `storage.Inspect`,
  the Rescan move, `POST /api/storages/probe`, and two spec corrections. `Test helper` (quince#699) is
  open and awaiting the code owner.
- **`quince#697` filed** — `Resolved()` defaults `storage.zfs.mode` to `exec` and the shipped image
  has no `zfs` binary, so the schema's default zfs mode cannot work in what we ship. Two measurements,
  three candidate shapes, no ruling. It existed as *"worth its own issue; filed with PR 2"* in the spec
  for several hours **after PR 2 merged and while no issue existed** — a deferral aimed at nothing,
  which is quince#320's lesson in miniature. Corrected in quince#698.
- **The Operator ruled the zero-storage gap** — option (a), any zero-storage start IS the onboarding
  state — so PR 9 is no longer held.
