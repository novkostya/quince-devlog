# 2026-08-17 — the bar was honest and still read as stalled

**A backup card told the truth for 184 seconds and nobody could tell it apart from a crash. Every
field was accurate; the screen was still wrong.** quince#376 / quince#808, opened as quince#1101,
quince#1102, quince#1103 and one slice held back.

The Operator asked for measurement before design, which turned out to be the whole of it. A recorder
went onto the staging stand sampling the job row at 1 Hz beside the kernel's own counters — dataset
bytes, the tool's `read_bytes`/`write_bytes`, NIC rx/tx — so *what the UI was handed* could be laid
against *what the machine was doing* on one clock. The credential problem solved itself:
`Engine.progress` persists the row immediately before it emits on the WebSocket, so `sqlite3
-readonly` on the app DB **is** the wire, and no admin session was needed at all.

**The first run, 12m42s, incremental over Wi-Fi:**

```
21:19:59  backing_up/starting   percent=null   ← 184 s, liveness `active` throughout
21:23:03  waiting_for_passcode                 ← one second
21:31:51  receiving             percent=100    ← 50 s more; verify+commit were 3 s of it
21:32:41  succeeded
```

During those 184 s the tool read 518 MB and pushed 263 MB while the dataset grew by **zero** — so no
size-watching heuristic would have caught it either. 24% of the backup, unnarrated.

**Both windows come from one guard in idevicebackup2** (`idevicebackup2.c:2523`, tag 1.4.0): the
status line prints only while `overall_progress > 0 && !progress_finished`. The percentage is the
*device's* figure, so nothing prints before the device sends one — and once it reaches 100 the flag
latches and nothing prints again, while the tool goes on moving and removing files. Reading the
pinned source rather than guessing is what turned two symptoms into one mechanism.

## What the measurement kept overturning

**`percent` is not honest — that conclusion came from a run whose batches happened to be small.**
The next night a single **2.68 GB** batch arrived and the percentage sat at **1% for 3m20s** before
jumping to 48. The device attaches its figure to each protocol message, so one large message freezes
it. Written down after one run, "monotonic and honest" would have shipped as a design premise.

**The 91-second freeze was real.** The Operator reported feeling stuck at `57.3 MB`; the record shows
`bytes_done` held at 57,252,249 for **91 s** with zero bytes, zero CPU and zero packets. Not a
display defect — an actual stall, of the known upstream kind. And `liveness` read `active` for all
608 samples of that run, because the server's own note needs `LivenessTimeout/6` = **3 minutes**. The
one mechanism for narrating silence is calibrated past the silences that occur. Gap histogram from
that run — 131 of 1–2 s, 12 of 5–10 s, one of 11–20 s, then one 26 s and one 91 s — is where the
20 s threshold came from. It is measured, not chosen.

**`files_received` counts protocol messages, not files.** It read 38 for a 5.9 GB run. quince#808's
`735 files` is the same artifact: the repo's own `noisy-joblog.meta.json` records `Receiving files`
appearing **735×** in that 94,034-file backup. The true count is printed on the tool's last line and
quince does not parse it.

## Three wrong explanations, and what they have in common

A timer read `26s` the instant a backup appeared. In order, I claimed it was: a stale job left
running in the store (a real ordering defect — `Object.values(byId).find()` returns the *oldest*
running job — but not this); then *"you weren't looking"* (jobs reach `Preparing` in ~1 s, so it had
rendered); then clock skew, **ruled out by measuring the server against an external reference and
finding it ahead**.

It was clock skew. The Operator's phone had *Set Automatically* off and had drifted 26 s ahead.
**I tested the clock I could reach instead of the one that was wrong** — and the shape repeats: the
first two explanations were each verified at the mechanism and never at the destination, which is
this project's most-filed defect arriving in a diagnosis rather than in a document.

Three tooling artifacts of my own came the same way: awk's `%d` is 32-bit and printed a byte count as
`-2147483648`, which I nearly reported as an integer overflow; `sqlite3 -json` pretty-prints, so the
record is a JSON *stream* and `head -1 | jq` calls it corrupt; and jq 1.7 preserves `100.0` as a
literal, so `=="100"` never matched and one section reported "never reached 100" beside another
counting 116 samples at 100. Every one was caught by re-reading the record rather than by the record
changing.

## What shipped, and what deliberately did not

The narration is derived entirely from fields already published — no wire change. An indeterminate
track for a null percent (the component's comment had promised one since it was written; the code
rendered a zero-width fill, and there was no test either way); `Preparing` and `Finishing up`;
elapsed time; and a note when a transfer goes quiet past 20 s.

**The copy was rewritten three times by the Operator and each round removed a claim.** A ticking
"nothing received for 45s" is a diagnostic readout — a person wants to know whether to worry, and the
answer does not depend on the number. A fixed *"your iPhone will ask for your passcode"* is false the
moment you have entered it, and quince cannot detect that: `idevicebackup2` does not report the
prompt until ~190 s later, where it lasts one second. A 20 s time box was too short to be seen at
all. The wording that survives states a **condition** — *unlock it if it asks* — true before, during
and after, and true on a device with no passcode, which quince equally cannot detect:
`PasswordProtected` reads **false** on a device that prompts, because it means *currently locked*.
Measured on hardware rather than assumed.

**What is NOT built** still needs a ruling, because `Job.progress` is frozen: a percentage that does
not freeze during a large batch, a real phase for the send window, and the true file count. The
narration describes those gaps honestly; it does not close them.

## Two process costs, both mine

**I took a runner name that was already live.** `r49` was chosen by scanning `~/scratch` for the
highest and adding one — but a `quince:local-r49` image had existed for seven hours. One of the two
places that would have said so, and I looked at the other. The consequences ran the whole session:
foreign edits appearing in my working tree, seven commits landing on a branch another session
created, and finally `runner set` refusing the name outright. The three open PRs carry `r49/`
prefixes while this session is now `r50`, so their events will wake the wrong seat. Not migrated —
GitHub will not retarget a PR's head — and covered instead by watching those PRs directly.

**`make push` reported success without publishing.** The tag resolved, `quince version` printed a
plausible string, and the container came up on a **twelve-day-old binary**, which the Operator saw as
every device unpaired with raw UDIDs and *"0 backups"*. Nothing was lost — 31 versions and 39 GB were
on disk throughout — but three independent signals agreed and all three were wrong. What caught it
was grepping the running binary for a string only the new build contains. Every deploy since verifies
the artifact, and the in-flight-backup guard that now precedes it self-matched its own command line
on first use, which is the fourth time a `-f` pattern did that in one session.
