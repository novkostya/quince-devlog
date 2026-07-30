# 2026-07-18 — (r) the gap protocol

2026-07-18 (Operator concern → process + first gap): (r) **the gap protocol** —
CLAUDE.md's "everything is decided" softened to canon-so-far; the program doc now
defines what an agent does at a gap: rung-local → decide in-spec + log (*rung-ruled*);
architectural → `PROPOSED (gap)` block in the canon doc + open question + STOP for
Operator ruling; silent deviation and silent doc-vs-reality "fixes" forbidden.
(s) **first gap processed — backup-encryption management** (Operator-spotted):
`Device.backup_encryption` from `WillEncrypt`; `POST /api/devices/{udid}/encryption`
(enable/change_password/disable; passwords via pty or `BACKUP_PASSWORD` env, argv
forbidden; on-device passcode step narrated); `backup.require_encryption: true`
policy enforced actionably at preflight; unencrypted devices get a persistent warning
(no Health/Keychain/passwords) and unencrypted versions carry `encrypted: false`
badges; one-password-two-uses documented (device backup password == vault unlock
password; quince sets it, never stores it). Landed in qn.3 scope.
