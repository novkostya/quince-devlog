# 2026-08-08 — a real ZFS dataset answered four unprovable questions and asked a fifth nobody had

**The Operator gave the runner container a real ZFS dataset. Within ten minutes it had discharged
`qn.6h`'s only hardware-blocked condition, and within twenty it had produced a failure mode that no
issue, no ruling and no spec had considered — one that turns an operation which is unconditional
today into one that is usually refused.**

`qn.6h`'s spec merged the same session ([quince#736](https://github.com/novkostya/quince/pull/736)).
No code exists. The rung is blocked on the question the lab created.

## What was unprovable that morning

[quince#730](https://github.com/novkostya/quince/issues/730) is titled *"the zfs branch is unproven
end to end: no real ZFS host, no real ssh, no real helper anywhere"*, and its owner line reads
*"whoever has the ZFS host."* The 2026-08-04 ruling required **rollback under load, measured on the
real topology**, in the spec. quince#730 made that unsatisfiable by the seat holding the work, and a
second Operator ruling on 2026-08-08 moved the measurement out of the spec and onto the
implementation PR for exactly that reason.

Then the Operator asked what it would take to give the container a real dataset, and the constraint
that decided the shape was already in `/proc`: **`uid_map: 0 100000 65536`** — an *unprivileged* LXC.
ZFS ioctls need real `CAP_SYS_ADMIN` in the initial user namespace, so `/dev/zfs` passthrough was
never the answer. **Which is why quince has hook mode at all**, and it meant the lab could be the
production topology rather than an approximation: the host owns `zfs`, the container gets a
bind-mounted dataset, and quince reaches the host through the forced-command helper.

The mount went in live. `lxc.mount.entry` needs a container restart, which would have killed the
session; the container's rootfs carries `master:360`, so a host-side `mount --rbind` under the
rootfs path propagated in with no restart. **The first attempt was wrong and worth recording**:
`nsenter -t PID -m` enters the container's mount namespace, where the host path does not exist. You
cannot rbind a source the namespace cannot see.

## The four answers

**H2 — rollback under load. Answer A: it succeeds.** Exit `0` with the dataset bind-mounted into a
running unprivileged LXC while three kinds of handle were held: an fd on a file, a child process's
fd, and a process whose cwd was inside the tree. Repeated with an **active writer** and a persistent
held **write** fd: still exit `0`, and the file held open for writing was **removed**.

**And the useful half is the caution, not the answer.** A rollback neither stops nor signals the
writers, and neither side gets an error. A loop reopening its path every 50 ms had its file removed
and recreated it immediately, silently. So answer A is **not** *"rollback is safe under
concurrency"* — it is safe because `engine.go:322-324` refuses reset with `409` while a backup runs.
**The safety is quince's guard, not ZFS's**, which makes that `409` load-bearing for correctness
where it reads like a tidiness check.

**`.zfs/snapshot` browse from inside an unprivileged container works.** The roadmap lists
unprivileged-container snapshot automount as a *"KNOWN minefield … (probe first)"*, and quince's
entire zfs read path depends on it. Probed; the tree and the marker both read fine through the
exact path `browseRoot` builds.

**Per-device quotas: 1620 GiB versus 9 GiB.** With no quota, the parent and child datasets report
identical `statvfs`. With `quota=10G` on the child, a target at the **parent** reports 1620 GiB and
a target at the **child** reports 9 GiB — a **180× overstatement**. The 2026-08-08 shape ruling moves
the tool's target to the parent, so a per-device quota stops producing a clean up-front refusal by
the device and starts producing **ENOSPC mid-transfer**. Combined with `engine.go:524`, which already
statfs's the parent, **nothing anywhere honours a per-device quota after this rung** — which is why
the condition is a declaration `deploy/storage.md` must carry rather than a footnote.

**The helper's guards, measured rather than asserted.** A rollback at a non-`@quince-*` snapshot is
refused; a `destroy` of a dataset is refused; and `rollback -r <snap>` has its `-r` **discarded by
the parse** — the newer snapshot survived. `deploy/storage.md` has claimed *"dataset destroy is
intentionally NOT reachable"* since it was written. It is now measured.

## The fifth question, which the lab asked rather than answered

The very first `list` through the helper returned `zfs-auto-snap_frequent-2026-08-08-0345`. **The
host runs an automatic snapshotter**, and:

```
cannot rollback to '…@quince-…': more recent snapshots or bookmarks exist
```

**`zfs rollback` refuses whenever ANY newer snapshot exists, including one quince did not take.**
Automatic snapshotting is ordinary ZFS hygiene, so a `@quince-*` snapshot stops being the most
recent within minutes of being taken. quince cannot force past it — `-r` is discarded, which is the
guard working as designed, since `-r` is exactly what destroys committed versions. **The verb's
safety and its unavailability are the same property.**

**So an operation that is unconditional today becomes one that usually refuses.** Reset is
`RemoveAll` on a directory quince owns, refusable by nothing. The 2026-08-04 ruling licensed
`rollback` as *available but destructive-if-misused*; this makes it **safe and mostly absent**, which
is the opposite failure and was not contemplated.

**The first mitigation written for it answered the wrong case**, and the architect caught that: *"do
nothing, the dirty head is resumable"* is the **retry** path. **Reset exists for when the head is
bad**, and there, doing nothing is not a remedy.

## What the day's defect turned out to be

Five instances across three seats in one evening, filed as
[quince-devlog#220](https://github.com/novkostya/quince-devlog/issues/220): **a claim about what
another document says, made from the citation rather than checked at the destination.** A canon PR
body describing a citation's target it had not opened; a milestone reference that resolved to
nothing; a rule listed from memory of its subject rather than its mechanism.

**Then it recurred one scale up, and that instance was mine.** After the Operator ruled the tree onto
the dataset root, the respec fixed the two sections the ruling named — and **six more sections kept
describing the withdrawn design**, including a flat contradiction where one section said the sentinel
could no longer reach a snapshot and another still insisted the removal ordering *"is the whole of
it"*. The commit said *"RESPEC D1 and D3"* and did exactly that. **The diff read as complete because
the section it targeted was correct.**

quince#409 established that *the heading is the only part describing the whole, so it is stale by
default after every flip*, and its own review added status tables. **A cross-document citation is a
third**, and **a design decision that other sections rest on is a fourth** — written once, never
re-read against what changed under it.

## What it does not establish

**One host.** One pool, one kernel, one ZFS release, an unprivileged LXC on PVE with `rbind`
propagation. Answers A and C are facts about that host, which is why the unobserved *busy mount*
branch is retained in the spec rather than deleted.

**quince itself was never in the loop.** The tree was hand-built and the rollback ssh-driven; no Go
code ran. `zfscli`, `RepairWorkingCopy` and the engine are still exercised only against the fake.

**No device, so the backup itself is unproven.** H1 remains the last hardware gate, and the lab
dataset — which is staying up — cannot answer it.
