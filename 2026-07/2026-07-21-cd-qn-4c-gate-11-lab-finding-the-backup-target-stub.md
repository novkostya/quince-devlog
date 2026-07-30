# 2026-07-21 — (cd) qn.4c GATE-11 LAB FINDING — the backup target stub must live on the storage filesystem; fixed as a lab-finding commit

(cd) **qn.4c GATE-11 LAB FINDING — the backup target stub must live on the storage
filesystem; fixed as a lab-finding commit.** The first real full backup (iPhone, ~40 GB, USB via
USB-over-IP) failed three times in ~30–60 s with zero bytes and `idevicebackup2 failed: exit
status 151`, phase `waiting_for_passcode`, despite the passcode being entered every time — while
the iPad's Wi-Fi incremental had just succeeded, so it read as "USB is broken". **Root cause,
proven both directions on the device within minutes:** mobilebackup2 asks the HOST for its free
space, and `idevicebackup2` answers with a `statfs` of **the target directory it was handed** —
it does NOT follow the `<UDID>` symlink into the work dir. quince passed
`$QUINCE_CACHE/backup-targets/<jobID>` (a 26 GB filesystem on staging), so the phone was told
26 GB, needed ~40 GB, and refused with `ErrorCode 105: Insufficient free disk space
(MBErrorDomain/105)` → **exit 151**. A raw run with the target on the storage filesystem (546 GB)
went straight into `Receiving files`. The iPad passed only because an incremental's delta fits in
26 GB. **Gate-blocking, in landed qn.4a code:** any device whose backup exceeds the cache
filesystem could never be backed up — every real iPhone. **Fix:** the stub is derived from the
work dir (`<dir of workDir>/.quince-targets/<jobID>`), quince-writable on every backend and
always on the storage filesystem; `ToolConfig.TargetRoot` REMOVED (a knob whose wrong value
silently breaks large backups should not exist). Note the engine's old `<backups>/…` default would
ALSO have failed under the zfs hook profile — the parent dataset root is root-owned, only
per-device children are chowned. **Second fix, same finding:** a failed job now reports the tool's
own last error line (`backup failed: Insufficient free disk space…`) instead of the exit status —
the bare code made three identical failures indistinguishable, and 151==105 is documented
nowhere upstream. **Fixtures first (hard rule):** `disk-full-105.{txt,meta.json}` (scrubbed real
capture) + `TestPrepareTargetLivesBesideTheWorkDir` + `TestFailedBackupReportsTheDeviceReason`.
**Process note:** the Operator predicted this failure mode from the `/cache` path before the run
("I'm afraid there might be a faulty free-space probe inside ibackup2 because /cache is on
rootfs") — the diagnosis was then run-anchored, not argued: a raw `idevicebackup2` into a
throwaway scratch dir on each filesystem, which is the qn.2b raw-run guard doing its job.
**Session backlog (filed, not blocking):** crash-orphaned stub dirs unswept by reconciliation;
the passcode narration unreachable in practice (the phase is learned in the same breath as the
failure); two `latest` badges until reload (client-side staleness, server verified correct).
