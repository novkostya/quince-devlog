# 2026-08-17 — the question was missing an option, and one measurement found it

**quince#1094 asked "fsnotify or polling?" for config file-watch. Measuring rather than answering
turned up a third option nobody had listed — `golang.org/x/sys/unix` is already a DIRECT dependency
and exports the inotify calls — which dissolved the dependency argument entirely and forced the
decision onto the ground that actually decides it.** Spec: quince#1126.

`/kickoff #1094`, runner `r54`. The issue is D12's last unbuilt half: a setting changed through the
UI applies immediately, the same setting hand-edited in `config.yml` still needs a restart. It is
ruled post-v0.1 and its own rung, unallocated, and it says of itself that it is *the tracker, not the
spec*, and that *nothing here is measured*. Canon §8 says a rung starts from a spec. So the unit of
work was the spec, and the spec's job was to answer three named questions with observations.

## The third option

The issue framed question 3 as a straight two-way call — add `fsnotify`, or poll `stat` — and called
it *"a D-level call given how few dependencies the core carries"*. Writing the probe required an
inotify binding, and the shortest route to one turned out to be `golang.org/x/sys/unix`, which is
**already in `core/go.mod`'s direct block**. The probe needed no `go.mod` edit. The repo also already
carries the `_linux.go`/`_other.go` build-tag pattern three times over, for `exchange`, `ficlone` and
`fiemap`.

So there are three options and **none of them costs a dependency**. The argument the issue reached
for does not separate them.

**That is the useful part, and it is uncomfortable in the right way**: the framing that made the
question look decidable was the thing that was wrong. Had the spec answered the question as asked,
it would have picked one of two options on a criterion that applies to neither, and the reasoning
would have read as sound.

## What decided it instead

inotify sees nothing when the writes happen on another host — so a `/data` on NFS or SMB, an entirely
ordinary NAS shape for this product, gets a watcher that is **silently inert**. It would fail in the
direction nobody notices: a hand-edit that does not apply looks exactly like the behaviour we have
today. Against that, polling reads the whole 218-byte file in **12.19 µs**, which at 1 Hz is about
0.0012% of a core, and the content comparison polling needs is required under inotify too — so
polling is the subset rather than the alternative.

## Two more measurements that changed the text rather than confirming it

**Self-write suppression cannot be done on the event stream, and now that is shown rather than
asserted.** quince's `AtomicWrite` and a hand-run `printf > tmp; mv tmp config.yml` produce identical
inotify sequences apart from the temp file's *name*. So the design does not try to identify the
writer at all — it compares content, which needs no debounce window and coalesces bursts for free.
The issue predicted this defect ("the defect every file-watch implementation ships first"); the
measurement is why the remedy is a comparison rather than a timer.

**The issue's own wording on question 2 understated the failure.** It says a naive watch on the file
path *"stops firing after the first edit"*. It is deleted: `ATTRIB`, `DELETE_SELF`, `IGNORED`, and
then nothing for **any** subsequent change, including in-place ones that never rename. Not a stale
descriptor — a removed watch.

**And the caveat the issue asked to have measured came back clean, with limits.** A watcher inside
the container sees host-side writes through a bind mount, for all three editor shapes. What that does
*not* cover is written into the spec rather than left implied: one kernel, local filesystems only,
and not the target hardware. Two gates are declared **owed to the Operator** for that reason.

## What was left undecided on purpose

Two calls are architectural and got recommendations rather than answers: `discarded` is a served
field whose definition widens once a *hand*-edit can be the thing that was refused (quince runs on
last-good, not on `Default()`), and whether the poll choice owes a `D<N>` at all — the recommended
option adds no dependency, so on its own terms it needs no ruling to permit, while the rejected ones
would. Rung allocation stays the Operator's, which is why the spec landed in a topic directory rather
than asserting a `qn.6` letter that would contradict the post-v0.1 ruling it was written under.

## One process note

`make pr-title-check REPO=… PR=<n>` reported **`DID NOT RUN`** on the implementer box: the target
invokes bare `gh`, which has no credential there — the wrapper is the only authenticated route. The
`--title-env` form needs no forge call and ran clean, so the check was not skipped, but the documented
`PR=` route is unusable from the seat that opens the PRs.
