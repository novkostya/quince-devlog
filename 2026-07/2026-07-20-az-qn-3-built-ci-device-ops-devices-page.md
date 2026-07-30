# 2026-07-20 — (az) qn.3 BUILT (CI) — device ops + Devices page

(az) **qn.3 BUILT (CI) — device ops + Devices page.** Cleared the pre-build
spec-review gate: spec + Rule check → **architect APPROVED with three amendments + two
rulings**, all folded in (Operator acks: hardware encryption coverage = `change_password` +
a disable→enable cycle; keep the freshly-paired container standing). **Interface facts verified
live** in the built image (libimobiledevice 1.4.0) — the STOP-gap cleared: `idevicebackup2`
supports interactive `-i` (pty getpass) **and** `BACKUP_PASSWORD`/`_NEW` env; per the spec's
pty-preference qn.3 uses the **pty** (password never in argv/env/log); `idevicepair pair` is
**error-and-retry** (not blocking) so `waiting_for_user` is a poll-until-`SUCCESS` loop;
`USBMUXD_SOCKET_ADDRESS` = `UNIX:<path>`/`host:port`; `ideviceinfo -x` keys + `-q
com.apple.mobile.backup -k WillEncrypt`. Shipped: **`internal/deviceops`** (argv wrappers with
the muxsup subprocess hygiene + a `GO_WANT_HELPER_PROCESS` fake-CLI harness; the pty-driven
encryption path via `creack/pty v1.1.24`); **`device.Enrich`** (lockdown identity overlaid on
the muxd-minimal shell, `device.updated` on change) + a bus-driven **enrichment driver**
(attach → `ideviceinfo`/`idevicepair validate`, per-UDID debounced, off the request path);
the **four frozen endpoints** (`POST …/pair` 202|404|409, `…/pair/validate`, `…/encryption`
202|422, `GET /api/ops/{id}`) behind a consumer-defined `DeviceOps` interface; the **`Op`
lifecycle** manager (running→waiting_for_user→succeeded|failed, `op.updated`); **audit** rows
for pair/encryption (no secret; design §6 list updated — amendment 3); **pairing-record
persistence** (whole-dir copy of `/var/lib/lockdown` ↔ `$QUINCE_DATA/lockdown`, amendment 1 —
survives a container recreate); non-demo wiring + a demo `DeviceOps` scripting the op flow;
and **UI** pair + encryption dialogs (assisted narration, unencrypted-banner CTA, USB-only 409
explained, passwords never in URL/log). **`make gates` + `make image` + `make gates-ui-e2e`
green** (added e2e **story 3**: encryption op narrates the assisted flow to success). **Story 5
headline gate proven** — a test asserts the password is in no argv/env/log/audit and only
reaches the child over the pty. **Coverage declared:** deviceops **80.2%**, device **97.6%**,
httpapi **71.8%**; **known-untested** (accepted debt, all low-risk error/edge or trivial
helpers): the enrichment-driver subscription-overflow `refreshAll` recovery, the ctx-cancel
process-group SIGKILL branch, the ops-map `pruneLocked` eviction (needs 200+ ops), the
lockdown mkdir-error warn branches, and the trivial `SetLockdown`/`encStartMsg`/`encDoneMsg`
defaults. **Lab gate 8 (fresh container → paired → encryption on real hardware) is the
remaining physical-presence step** — owned by this rung, not deferred. Not yet committed
(awaiting Operator).
