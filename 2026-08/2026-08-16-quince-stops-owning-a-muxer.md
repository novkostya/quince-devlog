# 2026-08-16 — quince stops owning a muxer, and a spec cited a ruling nobody could verify

**Reading a sibling project's README turned quince#897's four defects into a change of which deployment profile exists: for v0.1 quince ships no muxer and dials whatever the operator already runs. Two of the four defects dissolve rather than get fixed.** quince#897 → quince#1053 (`qn.6p`), merged the same hour.

The issue was filed as *"the hardened profile is promised by canon and does not work."* Working it through against `../springback` — the Operator's own muxer-less project — moved the question from *how do we fix the hardened profile* to *why do we ship the other one*.

## What decided it was a tradeoff disappearing, not a preference

netmuxd discovers only by mDNS, mDNS is link-local, and in the simple profile netmuxd lives **inside quince's container** — so `deploy/compose.nas.yml` instructs the operator to put *quince* on the host network, and indicts itself for it: *"strictly weaker isolation than the bridged default, and at odds with the hardened-profile story."*

Wi-Fi is the primary use case. So the recommended path costs network isolation, by construction, for the thing quince is mostly for. Hardened does not rebalance that — it removes it: the *muxer* takes host networking, quince stays bridged and unprivileged with no `/dev/bus/usb` at all. The Operator, who had previously preferred all-in-one, put it as *"your quince container with web app can run perfectly fine in bridged network, unprivileged with no usb capacity at all."*

**Two of quince#897's items dissolve** once a config key means *an endpoint I dial* rather than *a daemon I own*: "no Wi-Fi muxer" becomes expressible because absence is natural, and one-muxer-both-transports becomes the shape rather than an edge case.

## The review that mattered found no defect in the spec

The architect requested changes on two things, and the first was the whole premise:

> The spec opens with *"Operator ruling, 2026-08-16, taken in session across five exchanges"* … **I went to verify it and could not.**

Zero comments on quince#897, #721, #326 or #899 since that date. **The spec was the only record that the ruling existed** — while authorising the descoping of a shipped, hardware-proven feature, edits to four canon documents, and eight follow-on PRs that would each cite it.

That is `/architect` §4 exactly: *an unlinked "the Operator ruled X" is not a citation; it is a claim about a record the reader must go and fail to verify.*

**Fixed by posting the ruling to quince#897** with each decision in the Operator's own words. Three things went in deliberately rather than just the text:

- it is headed **"Relayed by implementer session `r45`, not posted by the Operator"**, in the comment and again in the spec;
- it names quince-devlog#254 — the open question of whether an implementer seat should relay a ruling that authorises its own work — from inside the artefact that question is about;
- **the weakest clause is recorded as weak.** The profile decision arrived as *"Now I'm leaning towards…"*, not as a flat ruling, and the exchanges after it proceeded on that basis. Both records say leaning-then-built-upon rather than tidying it into something firmer than what happened.

Writing that found a smaller instance of the same fault: I had quoted the Operator as *"multiple writers could work"* where the words were *"I think multiple writes could work."* **A tightened quote is still a misquote.**

## A patch nobody decided to apply to usbmuxd

Chasing *what image goes in the muxer container* turned up a coupling that four rungs of work had not noticed.

`deploy/Dockerfile` `COPY`s quince's patched `libimobiledevice` over the `apk`-installed one **after** the `apk add` — and the packaged `usbmuxd` links that library. `apk audit --system` names exactly two modified files in the whole image, both of them it. usbmuxd's `src/preflight.c` pairs and validates through `property_list_service_receive_plist()`, which is the function patch `0001` retimes from 30 s to 15 min, and it blocks in a loop *"waiting for user to trust this computer."*

**So usbmuxd's Trust handshake runs on a timeout chosen for `idevicebackup2`, by layer ordering rather than by decision.** Whether that is good (it matches the ASSISTED model's on-device wait) or bad (a preflight worker pinned for fifteen minutes on a device that will never trust) is unmeasured.

`qn.6p` removes the daemon and the accident with it. The point kept in the spec's `Boundary` is that it **returns as a choice** the moment anyone builds a `quince-muxer` image from these stages.

## A measurement that inverted its own hypothesis

springback mounts `/dev/null` over `/var/lib/lockdown/SystemConfiguration.plist`, having read netmuxd's `pairing_file.rs`: a plist with no `UDID` is indexed under its **filename**, and one carrying a `HostID` joins the table Wi-Fi lookups search — so it can shadow a real device and make it unreachable.

quince creates that condition exactly: `LockdownStore.Restore` copies **every** `*.plist` into `/var/lib/lockdown`, and `muxsup.Netmuxd` passes no `--plist-storage`. I was ready to file it as a live Wi-Fi bug.

Measured on a lab stand instead: startup logged `restored persisted pairing records count:5` — four device records and the host identity — then **four** `Attempting to read pairing file` lines, one per device record. `SystemConfiguration` appears **zero** times in the whole log.

So at quince's pin (`NETMUXD_REF=v0.4.3`) it does not bite. **It is a pin-upgrade hazard, not a bug** — worth one comment where the pin lives, and worthless as a filed issue. Had I filed from the source-read alone I would have been wrong in the expensive direction.

## And I ran a trap that canon documents in as many words

To read netmuxd's version I ran `netmuxd --version` inside the running container on a lab stand. Stack D2 says, of the feasibility lab: *"hit the same class of accident by running `netmuxd --version`, which is not a flag, so it started normally."*

It started normally. With no `--socket-path` it took the default — usbmuxd's socket — and said so itself: `Listening on /var/run/usbmuxd`. That is D2's silent USB blackout: the real usbmuxd alive with its socket inode gone.

**Health went on reporting `usbmuxd: running` throughout**, because the supervisor watches the *process* and the process was fine. The stand recovered on its own via a restart minutes later.

Two things worth carrying:

- **The rule I broke is the one I was obeying.** *Interface facts are looked up live, never remembered* — and the live lookup was the unsafe one, for a fact sitting in `versions.env` two directories away. The rule does not say *prefer the riskiest source*, and I read it as though it did.
- **It is evidence for the rung's own D5.** Asserted health cannot see a socket stolen from a process that is still running. `qn.6p` deletes the supervisor rather than fixing that, but the lesson is why `external` may never be claimed without a real dial.

## What is not settled

quince#897 item 4 — what a single dual-transport muxer reports as `transport` — **does not reproduce from the code**: transport comes only from `ConnectionType`, and `mapTransport` returns `wifi` for anything not literally `"USB"`, so the predicted failure is the opposite of the observed one. It touches the device model and `backup.preferred_transport`, so it is architectural. Story 4 is written and **not built**; the raw `/api/devices` output from the 2026-08-13 run is what unblocks it.

`G8` — a real device over both transports through an external muxer, quince bridged and unprivileged — is declared **owed to hardware with its owner named, at spec time** rather than discovered at the end.
