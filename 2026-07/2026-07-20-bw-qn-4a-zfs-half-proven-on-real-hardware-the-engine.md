# 2026-07-20 — (bw) qn.4a zfs half PROVEN on real hardware — the engine drives a committed, verified version on the real zfs-hook backend, end-to-end

(bw) **qn.4a zfs half PROVEN on real hardware — the engine drives a committed,
verified version on the real zfs-hook backend, end-to-end.** Stood up the deferred (bv) topology on
the lab rpool: a throwaway parent dataset, a constrained `quince-zfs-helper` forced-command SSH key
(create/snapshot/destroy/list/mirror; dataset-destroy + parent-escape both refused, verified), the
per-device child dataset `rbind,rslave`-propagated host→LXC→container (a host-side `zfs create`
appears live at `/backups/<udid>`), `storage.backend: zfs, mode: hook`. **The zfs legs (gate
15(a)+(d), (bv) enumeration):** (a) **engine→commit on zfs** — `quince backup` drove
`queued→…→succeeded` on the zfs backend; an ENCRYPTED backup (on-device keybag; Manifest carries
`ManifestKey`+`BackupKeyBag`), the `verifying` state ran A1's Verify on the committed tree,
`committing` cut the version snapshot `<ds>@quince-<versionID>` (~3.1 GB refer), `latest/`
reflink-mirrored. (d) **host `mirror` verb + `bclonesaved` live** — the verb ran on the real rpool
(`mode: hook-reflink`, "zero-space verified"); pool `bclonesaved` moved **+~3 GB** (measured `zpool
get bclonesaved`, the pool-level way — [[zfs-reflink-clone-facts]], never dataset `used`). (d)
**syncoid mid-write** — while a second backup was actively writing `working/`, a syncoid pass
replicated the child dataset to the offsite PVE host: both committed `@quince-*` restore points
intact (refer matched, working+latest trees present) + a sync-snap captured the dirty in-flight
`working/`. Offsite replication is safe during an active backup. (d) **iMazing-opens** stays an
Operator-GUI leg — flagged, not agent-verifiable. **Deploy-doc bugs (surface only once hook mode is
actually stood up — nobody had; all fixed in `deploy/storage.md`):** (1) the reference helper read
`target="$2"`, but quince sends the dataset LAST (`create -p <ds>`, `list … -r <ds>`) → it REFUSED
create+list; now last-arg. (2) the stock image ships no ssh client that `hook_cmd` needs; documented.
(3) a host-created dataset is root-owned → the unprivileged-userns container can't write `working/`;
the `create` verb now chowns to the container's mapped uid. Documented the two-hop (LXC + OCI)
`rbind,rslave` propagation too. **willEncrypt finding strengthened (backlog (bs)-(i)):** `unknown`
also arises from a COLD-lockdown enrichment race, not only an absent key → preflight hard-fails
`encryption_required` with no retry even on a device that WILL encrypt; the storage legs set
`require_encryption: false` (device still encrypts) to test storage, not re-litigate pairing.
**qn.4a zfs half CLOSED — only iMazing-opens (Operator GUI) remains.** M3's engine goal is now
hardware-proven on BOTH backends: hardlink engine legs (bs), zfs half (bw).
