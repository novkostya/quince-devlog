# 2026-08-14 — the zfs ceremony worked end to end, and almost every instruction in it was wrong somewhere

**A stranger-shaped walk through the zfs add-storage flow, on a rig configured from zero, produced a
committed snapshot — and eight defects, of which the Operator found seven by looking at the screen.
The code was right. The things the code SAID were not.**

The rig was rebuilt on `deploy/compose.nas.yml` with managed muxers and both transports proven, which
closed quince#651. Then the zfs leg: quince generated the key, the Operator pasted the
`authorized_keys` line, quince rendered the helper with their `PARENT` baked in, the host key was
compared and trusted, `Test helper` passed, and a real iPad backup wrote **into the dataset in
place**, verified, and snapshotted —
`labpool/quince/<udid>@quince-2026-08-14T08-18-…`, `REFER 3.78G`. That is quince#925's *"the first
backup is what proves that"*, discharged.

**Everything that went wrong was a sentence.**

- The fingerprint-compare command had been agreed on quince#921's review, filed as quince#924, and
  **never landed** — `main` still rendered a `/etc/ssh` glob. I asserted the corrected form as
  shipped three times in one day before a screenshot showed otherwise.
- The success line of `Test helper` ran two clauses together, so the half saying what was *not*
  tested read as the tail of a long line.
- The helper script was clipped at the column edge behind a scrollbar the platform hides.
- *Check this host's key* asked for a comparison already made, and offered a button that would
  write nothing.
- *Check* did nothing at all with the server unreachable — `fetch` has no timeout, so the promise
  never settled; and when it did fail it said *"could not check that path"*, blaming the one thing
  that was fine.
- An adopt cannot supply zfs config: `needsZFS = isNew && backend === "zfs"`, so the fields that
  carry `parent_dataset` and the transport are never rendered on that path, and Save stays enabled
  and fails server-side.
- A working storage's declaration vanished from `config.yml` 44 seconds after a restart, with **no
  log line naming the writer**.
- And a page-width comment still argued for a number the code no longer used.

**Three of my own attempts at "make the script wider" were worse than the problem.** A negative
margin widened the block by pushing it out *both* sides of its container — fine on the centred
onboarding page, and under the sidebar on the other one, where every line lost its first characters.
That is strictly worse than the clipping it replaced: the old bug hid the ends of long lines, mine
hid the starts of all of them. The lesson is a layer, not a value — a shared component renders in two
pages with different geometry and cannot know either, so width is the page's decision.

**The measurement that changed a ruling.** quince#790 proposed *"`sync` or `fsync` the probe source,
or retry once"* to stop ZFS reporting `EAGAIN` as unsupported. Measured, repeated rather than
sampled: `fsync` fails 3/3, `sync` succeeds 1 in 4, waiting 6s succeeds 3/3, and a 1-second retry
loop succeeds after **exactly five retries, three times running** — against a default
`zfs_txg_timeout` of 5s. The remedy is not a barrier, it is elapsed time, and the open question is
now whether a ~6-second storage-startup probe is worth moving that path from hardlink to reflink. I
had written "sync works" off a single passing run before repeating it.

**A number nobody had.** Two 3.7 G reflink versions cost **4.4 G of disk** — the first measured
figure for stack D5's whole argument.

**What the guards caught, including on me.** A test I wrote to pin the compare command passed
vacuously on an empty extraction; the probe that took it red is what exposed that. Copying a whole
file between clones of different vintages nearly reverted another seat's merged endpoints — visible
only as an unexplained deletion count in `--stat`. And a marker I deleted to clear one trap created
another, because quince's DB still held the storage id: the refusal that met the Operator was
correct, and I had built the state it refused.

Five slices landed — quince#949, #950, #952, #954, #958 — each branched from `main`, none stacked,
each rebased with `--onto <recorded-oid>` as its predecessor merged. quince#651, #817, #846 and #924
closed. quince-devlog#242 filed: an approved PR with auto-merge armed is knocked `BEHIND` by every
later merge and nothing moves it, which makes merging a **race against other merges during your own
CI run** rather than a delay. Five instances in one afternoon.

**Still ruled by nobody:** quince#790's settle-and-retry, quince#918's refuse-vs-warn, quince#849's
which-surface-explains-a-discarded-config — now an upgrade hazard rather than an edge case, since
quince#818 shipped and `hook_cmd` is refused by name — and quince#735's offsite snapshot mount. The
two gaps from the walk are owed write-ups.
