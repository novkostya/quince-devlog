# 2026-07-21 — (cb) qn.4c BUILT (CI) — netmuxd is co-supervised, and the three "it looks broken" defects are gone

(cb) **qn.4c BUILT (CI) — netmuxd is co-supervised, and the three "it looks broken"
defects are gone.** The rung's CI half is complete; only the inherited hardware day (gate 11)
remains. **Supervision:** `internal/muxsup` now describes any muxer daemon as a `Spec`
(name/role/argv/probe-network/address/rescan-applies) and a `Group` runs the two-daemon topology;
`cmd/quince`'s pure `plannedMuxers` resolves `devices.manage_muxer` + the two addresses into
supervise/dial/refuse decisions (table-tested). The qn.2b guarantees — own process group,
restart-with-capped-backoff, crash-loop → degraded, refuse-loudly on an already-served address,
killed on shutdown — are now **parameterized over a unix-socket AND a TCP daemon**, so netmuxd
inherits proof rather than just code. **The argv is load-bearing** ((bz)): `--host/--port` from
`devices.netmuxd_addr`, a **private `--socket-path`** (netmuxd deletes and rebinds whatever socket
it names — with the default that is the live usbmuxd's, i.e. a silent USB blackout), and
`--disable-usb` (D2's USB anchor until qn.7's audition); a derived path colliding with
`devices.usbmuxd_socket` makes quince **refuse to supervise netmuxd** loudly while still dialing
it. **Health took the clean break**: `muxers:[{name,role,managed,state,detail,rescan}]` replaces
the singular `muxer`; rescan stays **USB-only** (restarting netmuxd would tear a live Wi-Fi
backup). **Findings:** (i)-A `willEncrypt` maps exit-0-with-empty-output to **`off`** (an absent
key IS the device saying it will not encrypt; `unknown` now means a genuine read failure);
(i)-B **preflight re-reads the encryption state live** (`deviceops.RefreshEncryption`, reusing
qn.3's non-auto-pairing `Info`) whenever the cached value is not `on` — the cold-lockdown
hard-fail is gone, a fresh `off` still refuses actionably, and a still-`unknown` refuses with the
TRUE reason instead of implying the user disabled encryption (proceeding-on-unknown was
considered and rejected: discovering it after writing GBs is worse); (v) **`last_backup` derives
from the newest non-missing committed version** through an injected source read at merge time
(no cache to go stale — right after a restart, right for adopted versions, right after a delete),
plus `AnnounceBackup` on commit success for the live card update; (iv) **verified subsumed by
running, not assumed** (the architect's build flag) — a new `DeviceCard` test drives
backing_up(100%) → verifying → committing and shows the card already narrates each, so the only
missing piece was the last-backup line. **Gates:** `make gates` + `make image` +
`make gates-ui-e2e` green in quince-dev (e2e 6/6, incl. a new story: a dashboard-card backup runs
to success and the card lands on its real last-backup line **with no reload**). **Image smoke
test (the CI-side proof of the rung's promise):** `quince serve` in the image built this rung
reports both daemons `running` with the exact ruled argv, **both sockets coexisting**, TCP 27015
listening; a `kill -9` of the netmuxd child was **respawned by the supervisor** while usbmuxd
kept its original pid and a live socket (`idevice_id -l` exit 0). Coverage: muxsup **86.9%**,
device 97.8%, backup 83.8%, cmd/quince 20.9% (was 14.9), httpapi 72.0%, deviceops 80.3%.
**Deploy ((ca) discharged in advance of the gate):** the Wi-Fi/mDNS requirement is a first-class
header section in `compose.nas.yml` (host-networking answer, its honest isolation tradeoff, and
macvlan as the isolation-preserving alternative); `compose.lab.yml` documents the host-run netmuxd
equivalent incl. the `--socket-path` warning; **P1b** records the Wi-Fi twin of P1 in the
proposals ledger for qn.6. **One pre-existing finding filed (out of scope, has a home):** a job's
row goes terminal before its work is discarded and the single-flight slot released, so an instant
Retry can hit a 409 that says "a backup is already running" — correct refusal, misleading words;
the smallest fix is a distinct reason string. **Remaining: lab gate 11 (a)–(h), one Operator
hardware day** — both transports UI-driven with live progress, Wi-Fi on SUPERVISED netmuxd
surviving a container restart, honest mid-backup disconnect, the real last-backup line on a
device with pre-existing versions, encryption honesty, secrets absence, iMazing-opens. It also
settles whether the deployed bridged shape sees Wi-Fi devices at all, or needs host networking.
