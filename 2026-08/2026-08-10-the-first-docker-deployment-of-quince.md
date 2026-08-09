# 2026-08-10 — quince has now been deployed with Docker, and the file that documents it fails at its first line

**`compose.nas.yml` is the shipped example for *"Synology / QNAP / plain Docker host"* and nothing
had ever run it. It runs. It also cannot be run as written, and both halves were measured in the
same minute.**

## As written, unmodified

```
$ docker compose -f compose.nas.yml up -d
 Image ghcr.io/novkostya/quince:latest Error error from registry: denied
Error response from daemon: error from registry: denied
UNMODIFIED_UP_EXIT=1
```

quince#725 predicted this from the API — 404 on the package, no tags, no releases — and said plainly
it had not been reproduced. Now it has, and **the message is not the one predicted**: `denied`,
not `manifest unknown`. An anonymous pull of a non-existent package under an existing user namespace
gets the *authentication* refusal, so a NAS user reads *"you are not allowed"* and goes looking for
credentials they were never meant to need. It also means this run cannot settle whether the package
is absent or private — both look identical from outside.

## With an image override, and nothing else

A separate `docker-compose.override.yml` replacing the image. **`compose.nas.yml` was not edited**,
deliberately: editing the `image:` line would have hidden quince#725, which is precisely that the
image it names has never existed.

It comes up. `GET /` → 200, `GET /api/health` → 200, both supervised muxers start, `usbmuxd
v1.1.1_git20250201 / Using libusb 1.0.30 / Initialization complete`, and the storageless warning is
the correct one.

**And the file's Docker device instruction is now measured TRUE.** `device_cgroup_rules: c 189:*
rmw` plus the `/dev/bus/usb` volume bind, **no `privileged`, no `cap_add`** — every node under
`/dev/bus/usb` opens from inside the container. quince#650 established that the *nerdctl* branch of
that same comment is unexplained; the Docker branch now has a measurement behind it. That leaves the
two branches of one sentence in visibly different states, which is better than both being reasoned.

**Also: Docker 29's storage driver is `overlayfs`, not `overlay2`.**

## What it does not reach

quince#651's bar is compose-up → onboarding → **paired** → a completed, verified, committed backup.
This is compose-up. There is no iPhone on this rig and there will not be — opening
`/dev/bus/usb/001/001` is the permission the comment claims and is not the same as claiming a phone
through `usbmuxd`. And a vanilla Debian Docker host is what the issue asks for; it is not a Synology.

One usability note the run produced: `docker-compose.override.yml` is auto-loaded only for the
default file names. With `-f compose.nas.yml` it must be passed as a second `-f` — which a reader
following the file's own header would not know.

## And the default zfs mode still cannot work

Same image, same host: `zfs` and `zpool` absent, `ssh` present. quince#697 measured that on nerdctl;
this is the second runtime. The gap block is written into `docs/contracts.md` where the schema is
frozen — three mutually exclusive ways out, **none chosen** (PR quince#793). It sharpened rather
than softened while I was there: `hook` mode was driven end to end the same night, so the mode that
demonstrably works is the one you have to opt into.

The block could not go under the schema itself. `bin/gap-heading-check` exits 1 there — the next
three headings in that section are `RULED (was PROPOSED (gap))` blocks and the gate attributes the
following `RULED` to the live marker above it. The documented opt-out comment was **not** used: it
is for a block citing a neighbour's ruling, and this one cites none.

Refs quince#651, quince#725, quince#650, quince#697, quince#793.
