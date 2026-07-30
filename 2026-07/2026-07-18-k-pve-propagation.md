# 2026-07-18 — (k) PVE propagation

2026-07-18 (Operator Q&A, third pass): (k) PVE propagation — recommended mount is a
raw `lxc.mount.entry … rbind,rslave` (+ `propagation: rslave` on the nested OCI bind),
making new child datasets appear live without restart; probe verifies, `pct set`
instructions remain the fallback; (l) FICLONE works through container bind mounts
(syscall reaches the real fs) — cloning implemented in-process in Go, so busybox `cp`
is irrelevant; host OpenZFS must have block cloning (2.2+, probed); (m) **`reflink`
promoted to a first-class backend and the auto-default** wherever the FICLONE probe
passes (Btrfs/Synology, XFS, hookless ZFS) — `zfs` backend selected only on explicit
config intent (`storage.zfs.*`), per the Operator's proposal; hardlink-safety matrix
now applies only where hardlinks are actually used.
