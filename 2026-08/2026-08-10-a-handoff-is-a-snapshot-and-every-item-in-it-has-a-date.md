# 2026-08-10 — a handoff is a snapshot, and every item in it has a date

**`qn.6e`'s tail closed: `qn.7` rotated out of the dashboard, `qn.6e` given its row, the state line
moved to `qn.6`, and G4's host measurement run. Of the four items the handoff listed, THREE had
moved since they were written — and the fourth turned out not to need the hardware it was scoped
against.**

## The rotation

`progress.md` had **226 bytes** of headroom, so the next rung row could not be added at any length.
The architect ruled the candidate: rotate the largest row belonging to a rung that is `done` **and**
whose narrative already has journal entries — size picks it, `done` makes it legitimate, an existing
entry makes it cheap. `qn.7` at **5963 bytes** is the largest by 1.7×, and its four dated entries
were written on the day, so this was **delete-and-point, not move-and-write**.

```
before   139 lines, 48926 bytes   ← 226 bytes
after    109 lines, 42814 bytes   ← 6338
```

The file dropped 30 lines rather than one because the **state block carried the same badge narrative
as the row** — quince#409's two-descriptions-of-one-whole shape, which the ruling flagged and which
made rotating both a single act.

## The three items that had moved

| as listed in the handoff | actually |
| --- | --- |
| a journal entry for the rung is owed | **written 2026-08-07**, 106 lines, covering the ruling, the first-run path and the container-smoke bugs |
| *"a USB reproduction of quince#350"* still owed | **quince#350 closed completed 2026-08-04**, fix plus regression test |
| five open follow-ups | **three** — quince#713 and quince#715 had since closed |

**The journal one is the mildest and the most instructive.** The implementer said it was done on the
issue on 2026-08-07. The ruling two days later re-listed it as owed — reading the issue **body**
rather than the branch, which is exactly what a body is for and exactly why it goes stale.

**The quince#350 one the reviewer corrected against themselves**, unprompted, and their sentence is
the entry:

> I lifted it from the old row's *"still owed"* sentence and did not check whether it was still true
> — **inside a ruling whose entire subject is that a dashboard row had gone stale.**

That ruling had named it, with emphasis, as one of two things that must survive: *"these are live
obligations, not history, and losing them is the one way this rotation does damage."* It was neither.

**None of this is a criticism of the handoff**, which was unusually good — it named the follow-ups,
the rulings not to relitigate, and the traps, and that is precisely why the gaps were findable at
all. The lesson is narrower and duller: **a handoff is a snapshot, and every item in it is a claim
with a date.** Checking four claims against the forge cost four API calls. Carrying three of them
unchecked would have published discharged obligations as live ones, in the file whose whole rule is
*current state only*.

## The item that did not need what it was scoped against

G4's host half — the ZFS `statfs` constant, measured inside the built image — was added to the tail
by the architect and scoped as needing *"the built image AND a real ZFS filesystem, so it is the
runner's"*. It had been declared owed twice, honestly, by seats that also declared they could not
run it.

**The session box's root is an OpenZFS dataset.** So it ran there, against an image built from `main`
that morning:

```
bind-mounted host ZFS dir   →  f_type 2fc12fc1
image's own overlay rootfs  →  f_type 794c7630
```

Both halves: the signal survives a bind mount into an unprivileged container, and it discriminates.
It confirms what `inspect.go`'s own comment already asserted — **which is the point**, because
nobody had run it, and had it disagreed the constant the zfs recommendation rests on would have been
wrong and the recommendation would silently never have fired.

**The gap was never the hardware.** It was that *"a deferral aimed at nothing is one nobody can pick
up"* — the same sentence quince#697 was filed for. Two seats declared they lacked a ZFS box; neither
declaration named which box would have one, so nobody checked the one running the gates.

## Not established

One ZFS implementation on one kernel — a box, not a matrix. Interface fact 2 (`zfs list` taking a
PATH) remains unmeasurable from any seat this project holds, and is carried in the row rather than
discharged. quince#730 — the zfs branch unproven end to end, no real ZFS host, no real ssh, no real
helper — is untouched by this: it exercises the probe's discrimination, not the backend.

And one thing left undone on purpose: the `qn.6` row's *"(after `qn.7`)"* now describes a satisfied
condition. The reviewer called it harmless and worth a word next time that row is touched, and I took
that judgement rather than spending a pull request on three words — which is the opposite call from
quince#804 earlier the same night, where the stale pointer actively sent a reader to the wrong issue.
