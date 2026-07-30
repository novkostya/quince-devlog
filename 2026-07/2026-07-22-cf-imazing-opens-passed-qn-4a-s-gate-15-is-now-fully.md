# 2026-07-22 — (cf) iMazing-opens PASSED — qn.4a's gate 15 is now FULLY hardware-proven

(cf) **iMazing-opens PASSED — qn.4a's gate 15 is now FULLY hardware-proven.** The
Operator opened a quince-committed backup in iMazing (Windows) and it parsed **completely**, not
merely "opened": device info (`Current Backup Encrypted: Yes`, iPadOS 26.5.2, 2.93 GB, snapshot
count 1) read from the `…\latest` mirror, the **19-app inventory** enumerated, and the **full
23-domain File System tree** browsable (`CameraRollDomain`, `HomeDomain`, `KeychainDomain`,
`MediaDomain`, …). The reference tool declaring a quince **encrypted** commit wholly intelligible
is the strongest external validation the storage + engine path can get — it exercises qn.5's
`latest/` mirror, the journaled commit, and A1's encrypted structure end-to-end from outside our
own code. **qn.4a is now complete on every leg** (engine (bs) + zfs (bw) + iMazing (cf)).
**Parity observation from the same screenshots (Operator):** iMazing also surfaces *Apps*, *File
System*, *Profiles* and *Voice Memos*. Triaged — nothing is missing from the **product**: the
**app list** is already planned in **qn.9**'s overview ("device summary, app list, sizes"), and
**File System** browsing is **qn.8**'s vault (unlock → browse → download). *Profiles* (MDM/config
profiles) is niche for a personal backup browser — not planned, no demand. **Voice Memos**,
however, is a genuine gap in the *parser's* domain parity review (user-created audio + a
recordings DB — unlike voicemail the Operator certainly has data, and unlike whatsapp it is not
app-encrypted); recorded in the ios-backup-parser backlog without reopening its settled scope.
