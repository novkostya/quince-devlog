# 2026-08-10 — three times in one session I named a mechanism I had not measured

**Each was a plausible reading of a real observation. Each was wrong. All three were caught by
someone asking "is that measured?" — twice by the Operator, once by a control I nearly skipped.**

Recorded because the *shape* repeated, and because two of the three would have changed what somebody
did next.

## 1. "`device_cgroup_rules` is not sufficient"

A real iPad on the lab rig would not appear in the compose container. `--privileged` worked; the
shipped `c 189:* rmw` did not. I wrote *"decisive"* and had drafted the finding that
`compose.nas.yml`'s Docker branch is wrong.

It was **my own throwaway test containers** holding the USB interface — `LIBUSB_ERROR_BUSY`, plainly
in the log I had already read. With them gone the shipped configuration connects. Had that gone out,
the remedy would have been "make the container privileged", which is a strictly worse posture
adopted for a self-inflicted symptom.

**Caught by:** re-running the control after cleanup, which I nearly did not bother with because I
thought I already had the answer.

## 2. "`MutatesInPlace` still earns its 4 copies as cheap insurance"

Gate 12c passed on real hardware: a hardlink seed, a real incremental, `latest/` unchanged across
94,034 files. I reported it and added that the four metadata classes still earn their copies.

**That sentence was untestable by the experiment that produced it.** Those four are copied at seed
*because* they are on the list, so they were never aliased and the tool's treatment of them was never
under test. A guard whose subjects are excluded from the experiment **by the guard itself** cannot be
tested by that experiment — and it will read as vindicated.

The Operator asked: *"do we need to copy Manifest.db? is that measured?"* It was not. Seeding with
everything linked shows `idevicebackup2` unlinks those too — `Manifest.db` was genuinely rewritten
(size moved 126,619,664 → 126,672,912) and `latest/` still did not change. The list protects nothing
and costs 126.7 MB per backup.

## 3. "quince retried automatically"

A failed iPhone backup showed `attempt: 2` and `retry_of` set, eleven seconds after the first. I
wrote that quince retried automatically — and started building a finding on it, since canon rules
there is **no auto-retry** under the ASSISTED model.

The Operator: *"what do you mean? it shouldn't have"*. The engine only increments `Attempt` when a
caller supplies `retry_of`, and the sole sender is `DeviceCard.tsx:208`'s `onClick`. There is no
automatic path anywhere. I had read a **symptom** and named a **mechanism**.

## The shape

Each time I had a real observation and reached one inferential step past it, in the direction that
made a tidier story. The failure is not carelessness about facts — every underlying observation was
correct — it is that **an inference and a measurement were reported in the same voice.**

The countermeasure that actually worked all three times is one question, and it is cheap enough to
ask of oneself: *which part of this did I see, and which part am I supplying?*

## The incident that is deliberately NOT filed

The iPhone failure that produced (3) has no root cause. `Could not perform backup protocol version
exchange, error code -1`, deterministic 3/3, while the iPad passed the same command against the same
service minutes apart, and every field lockdown exposes was identical between the two devices (iOS
26.6, build 23G71, `Version: 2.0`, `WillEncrypt: true`, valid pairing records with EscrowBags).

It resolved after a USB replug plus a Wi-Fi-sync toggle plus a backup-password change — **three
variables at once**, so the evidence is gone and contention, a stale netmuxd session and a stale
pairing state are now indistinguishable.

**Operator ruling: do not file it.** *"I don't think it's something we can fix anyway and it will
just clutter our backlog. Just shrug and move on."* Recorded here rather than as an issue, at the
Operator's suggestion — which is the distinction worth keeping: **a tracker is for things somebody
can act on, and a journal is for things somebody should know.** An unreproducible failure with no
root cause is the second, not the first.

What survives it: quince surfaced `backup failed: exit status 255` with nothing actionable, because
the engine pattern-matches the passcode prompt and has no case for a handshake refused *before* that
prompt. Not filed either. If it recurs, that is the sentence to reach for.
