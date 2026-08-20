# 2026-08-20 — there is no safe way to ask "can the muxer record a pairing", so the check has to move after the walk

**`qn.6r` specced and two slices merged. The rung's central finding is a negative one: every probe
that would answer the question before a user walks to their phone either destroys a real pairing
record or leaves one nothing can delete. So qn.6p D7's refusal cannot be repointed — it can only be
replaced by a check that runs afterwards and tells the truth.**

Follows [the entry on the model moving at qn.6p](2026-08-20-pairing-records-belong-to-the-muxer.md),
which established that pairing records are the muxer's. This is what happened when the rung that
follows from it was specified.

## The question the rung had to answer

qn.6p D7 is an Operator ruling with a stated purpose: *"a pairing that cannot be recorded is not a
pairing"* — refuse **before** somebody walks over to the phone and taps Trust. Its implementation
write-probes quince's own `/var/lib/lockdown`, which after the split is a container-local directory
no muxer reads. The check is in the right place in the flow and asks the wrong filesystem.

So: what *should* it ask? The muxer, obviously. The rest of this entry is why that turns out to be
unanswerable in the direction D7 wanted.

## Four measurements, taken at pinned refs

netmuxd `ac8da97` and libimobiledevice `1.4.0`, fetched and read rather than recalled.

**`SavePairRecord` overwrites unconditionally**, and answers cleanly — `Result(0)`, or `Result(1)`
on a write error. A well-behaved probe *target*.

**netmuxd does not model `DeletePairRecord`.** The request `match` has six arms and no wildcard, so
those are all the variants there are. An unmodelled type with no upstream configured is
`warn!(…); continue` — **no reply is written at all**. `pairing_file.rs:217` has
`remove_pairing_record`; nothing calls it.

Those two together kill the obvious probe. Against a **real** UDID it destroys that device's
record. Against a **sentinel** it leaves a file nothing can remove over the protocol — and
`update_cache` walks every file in the store, parses it, and adds it to `paired_udids`, so the
sentinel becomes a phantom paired device. That is the same class as the `SystemConfiguration.plist`
shadowing the compose file already warns about.

**`ReadBuid` is not an alternative.** It writes only when a field is missing, and the write is
best-effort — a failure is a `warn!` and the identity is returned anyway.

**And the one that reframed the rung: libimobiledevice discards the save result.**

```c
/* src/lockdown.c:1024 */
userpref_save_pair_record(client->device->udid, client->device->mux_id, pair_record_plist);
```

No assignment. `ret` stays `LOCKDOWN_E_SUCCESS`, so `idevicepair` prints `SUCCESS: Paired` and exits
`0` **when the muxer refused to save**. quince matches that string and reports the op `succeeded`.

**That is a state-honesty violation live on `main`, and it is a fourth symptom the issue never
named.** It also means the architect's suggested fallback — *an actionable failure at pair time* —
has nothing to trigger on. There is no error string, no exit code, no signal from the tool.

## So the answer is a post-check, and the walk is no longer preventable

D7's **intent** survives: a pairing that was not recorded is not reported as one. D7's **refusal
before the walk** does not. That is a user-visible retirement of half an Operator ruling, so the
spec says so at the decision rather than shipping something shaped like the original, and the
question went back to the Operator. It is still open.

One case stays refusable and is kept: an unreachable muxer. Narrower than D7, and not offered as a
substitute for it.

## What review caught, and it was the better half of the design

The first post-check asked `ReadPairRecord(udid)` after the pair and treated a reply as proof.

**Presence answers *is there a record*. The rung needs *was one just written*.** Those come apart on
any stand that has been running a while: a device whose record is stale — phone reset, trust
revoked — still has a **file** in the store. `contracts.md:1109` is explicit that `paired` means a
lockdown validation and **not** record presence, so quince offers Pair for exactly that device. With
the store unwritable, the tool prints SUCCESS, and the **stale** record answers the presence check.

The rung's headline claim, failing by the mechanism it was written against — in the *likelier* of
the two cases, since the empty-store case only arises on a device that has never paired here.

The fix is to read **before** as well and compare a hash. Same hash means the save did not happen.
Hashing rather than keeping the bytes also made the secrets story stronger than it was: what
survives across the user's walk to the phone is 32 bytes, not a private-key-grade record.

**Two residuals are written down with their direction**, which is what makes a residual a
disclosure rather than a hedge: a byte-identical re-save would read as *not recorded* (unreachable —
`lockdown.c:867` mints a fresh `HostID` per pair — and conservative, since quince under-claims), and
a concurrent third-party writer would read as *recorded* (no lock over the muxer's store, and this
rung does not invent one).

## Three smaller things, one of which was time-critical

**A canon line was wrong in both halves and the first fix caught one.** `stack.md:128` read *"No
`--plist-storage`: netmuxd reads … the same pairing records quince already persists and restores"*.
The reads/writes half was obvious. The other half — *"No `--plist-storage`"* — is contradicted by
`deploy/compose.yml:44` on `main` today, which passes exactly that flag. The bullet described what
quince passed when it **supervised** netmuxd; qn.6p retired the supervision without retiring the
sentence.

It was caught before the PR opened, which mattered: that file is `CODEOWNERS`-owned, so a second
pass would have cost a full round trip through the one approver already holding the D3 question.
**A canon line with one clause fixed reads as a line that was checked.**

**A gate that would have verified nothing.** G6 said *"both compose files parse … and the muxer's
store is outside `./quince/data`"*. Writing the correction to it surfaced that
`compose.host-muxer.yml` has no store at all — its muxer is the host's usbmuxd — so the third clause
had nothing to check there and would have reported a pass for a file it never looked at. Rewritten
to assert the absence rather than skip it. **Found by the correction, not by design**, which is
worth recording accurately: the credit belongs to the act of rewriting, not to foresight.

**A spec claim falsified by its own implementation.** The same discovery meant D6 touches one
example, not two. All three places in the spec were corrected in the diff that found it.

## Filed rather than absorbed

- **quince#1314** — netmuxd regenerates `SystemBUID` on every `ReadBuid`, because the shipped
  compose masks its host-identity file with `/dev/null`, which `path.exists()` accepts and which
  reads as zero bytes. Mechanism proven from source; whether a device rejects a session whose
  `SystemBUID` differs from its stored pairing is device-side behaviour nobody has measured.
- **quince#1324** — the `▸ UPGRADING?` note added by the store move has no removal condition, so it
  is permanent by default: eight lines telling every future new user how to migrate from a state
  they never had, in the file they are told to start from.

## What none of this proves

**No frame has been sent to a running netmuxd, and no device has been paired through the shipped
stack.** Every claim here is upstream source at pinned refs plus measured mounts. The pinned image
digest is also unverified against `ac8da97` — the compose comment asserts the provenance; the source
was read at that commit, not the bytes in the image. And the store move's migration is reasoned, not
run.

All of it is `qn.6p` G8's to close, declared owed at the top of the spec rather than discovered at
the end.

## Where it stands

Merged: the spec (quince#1315) and the store move (quince#1322). Approved and waiting on the
Operator as code owner: `LockdownStore`'s retirement (quince#1320). **Blocked on the D3 ruling:** the
slice that moves the check, and the slice that removes the wire field behind it.
