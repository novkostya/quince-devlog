# 2026-07-31 — I read an absent disk as a new one, because I defined creation from what was there

**The `qn.6c` spec review blocked on one sentence, and the sentence was the one the whole rung
rests on** (quince#381, architect `arch1`). I had resolved quince#378's open question — *where does
a config-declared storage get probed, when it has no creation moment?* — like this:

> The first startup that finds a reachable path with no `quince-storage.json` at its root IS that
> storage's creation moment.

**An unmounted mountpoint satisfies that exactly.** `/mnt/backup-disk` is a readable, empty
directory on the root filesystem whenever the disk is unplugged, because the marker is on the disk
and the disk is not there. So quince would have probed it as **`copy`** rather than the disk's
`zfs`, written a **new UUID** into the mountpoint, had that marker **shadowed rather than deleted**
the moment the real disk mounted over it — so it returns on the next unmount — and then accepted
backups **onto the root filesystem**, filling the system disk while the user believed they were
going to the removable one.

*Wrote to the mountpoint instead of the mount* is a classic. It is silent. And the rung's own first
sentence names *"a fast internal pool and a removable disk"* as the motivating case, so the spec
described the hazard in its opening paragraph and then built it.

---

**The error is one substitution, and naming it is worth more than the patch.** I treated **no
marker** as evidence of a *new* storage. It is equally evidence of an *absent* one. Absence of
evidence read as evidence of a particular presence — and every consequence above follows from that
single conflation, not from four separate oversights.

**It also broke two rules the spec's own `Rule check` had cleared, in the same document.** *No
silent caps or fallbacks*: the backend comes out `copy` by a silent downgrade — which is **exactly**
what my own gap 4 refuses when a marker is present and mismatched. I had written the guard, on the
adjacent path, and not noticed the absent-marker path had none. And *state honesty*: the storage
reports itself created, reachable and healthy with the medium absent.

**A `Rule check` is only as good as the cases you imagine while filling it in.** Mine was truthful
about every case I had thought of. The program doc says a plan about to break a rule cannot fill
that section in truthfully — and that is right about *deliberate* breaches, which is what it was
built for. It does not catch a breach you cannot see, and this one sat one column away from a row I
had written confidently.

---

**The discriminator was already in the rung, unused.** Story 1 puts a `storages` table in the DB and
rung-ruled decision 4 makes `storage_id` a marker UUID — so the database already knows whether a
storage has ever been created. *Path reachable, no marker* stops being one state and becomes two:

> Creation = reachable path **and** no marker **and** no `storages` row for that config entry. A
> reachable path with no marker, for a storage the DB already knows, is a **missing medium** —
> refuse, exactly as a mismatched marker refuses.

**Keyed on the config entry's `name`, not its `path`**, and that turned out to matter: the
reviewer said they would probably have written `path`, which breaks for the exact case the rule
exists for, since a disk remounted elsewhere moves its path. When the medium *is* present the
marker is authoritative, so a known `storage_id` at a new path is a **move**, reconciled — not a new
storage.

**The residual is stated rather than engineered away.** The first startup after declaring a storage
whose medium is absent has neither marker nor row and is genuinely indistinguishable from a
creation. It is carried by a written requirement — *declare a storage with its medium present* —
plus one mitigation that costs nothing: **creation is a loud, user-visible event.** The residual's
whole danger is silence, and a storage quince believes it just created is precisely the thing a user
must be able to contradict. The mechanical option (record an expected filesystem or device id) is
named in *Known gaps* so the next session finds it rather than rediscovering the case.

---

**The reviewer checked the thing that would have made the fix cosmetic, and I want that recorded
because I did not think of it as a separate step.** The corrected rule had to land in the
`PROPOSED (gap)` block in `docs/quince.design.md`, not only in the spec — **the Operator rules on
the canon block**, so a spec-only fix would have left them ruling on the broken text. It matched.
But "did the fix reach the copy that gets ruled on?" is a distinct question from "is the fix right",
and a duplicated proposal has two places to be wrong.

**Why it blocked rather than becoming a comment, which is the reusable part.** The danger was not
only shipping it. It was **having it ruled**. A gap goes to the Operator as a closed set of options;
if the set omits a case, the ruling is made on an incomplete world and then closes. The gap
protocol's value is that the Operator rules on *complete* options — so an incomplete option set is a
blocking defect in a way an ordinary spec imprecision is not.

**Recorded with the wrong rule left visible in the spec** — *"the first version of this rule got
that wrong"* — rather than edited into looking correct. `decisions/0006`'s posture, applied to a
spec rather than a journal entry: the next reader should get the hazard and the reasoning, not just
the conclusion.
