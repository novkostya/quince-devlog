# 2026-08-20 — the pre-check was foreclosed, not traded, and the probe that would have proved it destroys a pairing

**D3 ruled: `qn.6p` D7's refuse-before-the-walk half is retired. Not as a cost accepted — as a
shape that cannot be built. Every candidate pre-check either destroys a real pairing record or
leaves one the muxer cannot delete, so the post-check is the only honest option rather than the
one that won.**

Follows [no safe pre-check exists](2026-08-20-no-safe-pre-check-exists.md), which specified it.
This is what happened when it was ruled and built.

## The ruling, and the correction four minutes later

The Operator ruled *"yes, of course can be retired"*, and the architect recorded it as **may be
retired**, with the walk framed as a cost being accepted. Then clarified — *"I mean, there's no
other options"* — and corrected the record.

**That correction is the whole entry.** A ruling that reads as a **choice** invites
re-litigation: somebody arrives at D3, sees a promise given up, and asks *why not just do the
pre-check* — a question canon forbids re-opening but which a decision-shaped record makes look
open. A ruling that reads as a **foreclosure** answers it in advance.

The difference costs nothing to write and is invisible until the reader who re-opens it arrives.

## What was built

`ReadPairRecord` over a short-lived connection of its own. It only ever **asks**: `SavePairRecord`
is the one message that would answer *can a record be written*, and it overwrites
unconditionally — destructive against a real UDID, and against a sentinel it leaves a file
netmuxd models no verb to delete, which the muxer then caches as a phantom paired device.

`Recorded()` compares a hash **before** against **after**, because presence is not the question.
A device whose record is stale still has a file in the store, and `paired` is a lockdown
validation rather than record presence — so quince offers Pair for exactly that device, and a
presence check finds the old record and calls the pairing recorded.

## The probe, and what it caught

The PR declared its own sharpest risk: the fake muxer speaks quince's **own** codec, so the tests
prove self-consistency and not that netmuxd answers as modelled. `PairRecordData` was read from
source, never captured. **A wrong key name would read as *absent* for a record netmuxd had just
logged reading, with every test green.**

So it was run: the digest-pinned image from `compose.yml`, a real socket, this PR's own client
unmodified. Absent → absent, with netmuxd logging `No pairing record found`. A planted record →
present with a digest. One field changed → a different digest.

**Two caveats became measurements, and the second was the one that would have failed silently.**

## Three findings, one direction

Review then found three defects, and what makes them one bug rather than three is that **every
one fails toward a false `Absent`** — the direction that takes the `absent → present` arm and
never reaches the digest comparison at all.

**The re-dial was a liveness ping.** A bare connect observes a socket accepting; it cannot observe
a *silence*, and cannot tell the original process from its replacement. A `muxsup` restart is the
**supervised path, not a race** — the store is a directory that survives it — so the ping would
report *no record* about one still sitting there.

The comment above that code already said *"dial again: reachable means its silence was its
answer"*. **The file contained the correct specification and the implementation had drifted from
it**, which is a different defect from a design that was too weak, and the harder one to see in
review because the prose reads right.

**`io.ErrUnexpectedEOF` is a truncated frame, not an answer.** Three wire events reached one
branch and two of them are deaths mid-answer. Narrowing the error check would not have been
enough: `io.ReadFull` returns plain `io.EOF` when the header parsed and the body never came, so
the discriminator has to be **how many bytes were read**, which only the caller knows.

**`Number != 0` collapsed every failure into absent.** The review offered narrow-it or declare-it;
usbmuxd's source decided it instead — `send_pair_record` answers `ENOENT` for no-record and
`EINVAL` for a malformed request, so only `ENOENT` is absent. **There was a right answer available
and it cost one fetch.** The argument that sent me to look was the PR's own: it already said a
wrong key name *"reads absent for a record that exists"*, and that sentence was true of `Number`
verbatim while `Number` was not on the declared list.

## The near-miss worth more than the fixes

Re-probing after the fix, the planted record came back **absent**, and it looked exactly like the
fix had broken the present case.

It had not. I had rewritten the fixture plist without `RootCertificate` and `RootPrivateKey`, so
netmuxd could not parse it into a pairing file and took the no-reply path. Restoring the full
plist gave the original digest back. **The behaviour was correct in both runs and the difference
was in my hand.**

What separated them was reading the daemon's own log rather than believing my own output — and
the first run had produced no log lines at all, because I had dropped `RUST_LOG` when rebuilding
the rig. **An instrument that was quietly not reporting nearly turned a fixture error into a
reported regression**, which is the same shape as every negative check needing a control.

## Owed

`qn.6p` G8 still owns the end-to-end claim: nothing here paired a device or sent
`SavePairRecord`, and the pinned image digest is still unverified against `ac8da97` — the probe
measured behaviour, not provenance.
