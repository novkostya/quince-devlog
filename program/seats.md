# Seats — standing up the agent boxes from nothing

**Who this is for:** someone with this repository and somewhere to run three Linux machines. It
should be enough to rebuild the whole agent side of quince from scratch.

**A seat is just an Alpine Linux machine with ssh and outbound internet.** A container, a VM, a
cloud instance, a spare laptop — the design cares about *what a box holds*, never about what created
it. The Operator's own fleet runs on Proxmox and §8 offers the scripts for that, but nothing in
§§1–7 depends on it.

It deliberately contains no addresses, hostnames or sizing — those live in `local/environment.md`,
which is Operator-local and gitignored. Where a concrete value is needed this file names a
placeholder and says where the real one lives.

Written 2026-07-29 from a rebuild done that day. Every gap in §4 was hit during that rebuild, not
imagined.

## 1. What the seats are, and the property they exist to hold

Three machines, three roles. The whole design exists to keep one property true:

> **`approver ≠ author`.** No single machine can both write a change and approve it.

| role | identity it holds | can | cannot |
| --- | --- | --- | --- |
| `implementer` | the coder App's private key | author, push, open PRs, file issues | approve, merge |
| `arch` | the reviewer App key + the Operator's PAT | review, approve, merge | author — it must not hold the coder key |
| `supervisor` | **nothing** | coordinate, measure, prepare | author *or* approve |

**The design is to enforce it twice**: `deploy/runner/preflight` refuses to **start** a box holding
the wrong credential, and the `bin/gh-*` wrappers refuse to **run** on one. A hand-run command
should not be able to cross a boundary the service refuses to cross.

**It is enforced once, at start.** Stated rather than implied, because a runbook that describes the
design as though it were the state is the defect this project files most often:

- **`preflight` enforces it** — it refuses an `arch` box holding either implementer credential, and
  requires one on an `implementer` box. That half is live (quince#203).
- **The wrappers do not**, for the credential this document is about. `bin/gh-arch` and
  `bin/gh-review` check for a bot token and nothing else, so an `arch` box holding
  `quince-coder.pem` can author with `gh-coder` and approve with `gh-review` and **no wrapper
  objects**. `bin/gh-coder` refuses the *approving* credentials from its side, which closes one
  direction of three. Tracked as quince#204.

**The table below is the rule. Whenever it and the tools disagree, this section is the record of
which — check quince#204.** Phrased that way deliberately: the first version of this paragraph said
*"until quince#203 lands"* and was false four minutes after it was written, because the issue merged
while the document sat in review. A sentence with a fuse in it is a sentence that will be wrong and
will look right.

Until the tools agree with the table, **the part they do not cover is carried by whoever provisions
the box.**

**A naming collision, flagged because this project's docs are its interface.** `supervisor` already
means something else here: `docs/quince.design.md` has a **`muxer supervisor`** and a **`backup
supervisor`**, both Go subprocess managers, and `roadmap.md` and `progress.md` use the term the same
way. **In this document `supervisor` is a seat — a machine — and never the product's process
manager.** A reader moving between here and `quince.design.md` gets no other signal that the referent
changed.

**Canon does not yet describe this seat.** `CLAUDE.md`'s "How work runs" names implementer,
architect and Operator. A third seat with a stated security property belongs there too, and that is
**owed** — it goes in the same batch as `decisions/0014`'s canon rewrite rather than being discovered
separately. Until then, canon and this file disagree about how many seats exist, and canon is the one
a session reads first.

**The supervisor is the seat the Operator talks to.** Holding no forge credential, it cannot be the
author of record — it cannot muddy the property even by accident. Stated honestly: it *does* hold ssh
into the other two, and root ssh to a box holding a credential **is** that credential. The supervisor
buys **attribution, not isolation**. That distinction is the point — the failure it prevents is an
agent committing under the Operator's own identity from the Operator's own workstation, which is what
happened before it existed.

## 2. What a seat needs before you provision it

Any Alpine machine reachable over ssh, with:

- outbound HTTPS (GitHub, the Claude Code apk repository)
- `openssh` running, key-only root login, your public key at `/root/.ssh/authorized_keys` mode `600`
- a resolvable name, if you want to reach it by anything but an address
- enough disk for a container runtime and image layers on the two working seats; the supervisor
  drives rather than builds and needs materially less

**Some images ship no `openssh`.** `rc-service sshd start` then fails with
``service `sshd' does not exist``, which reads like a broken service and is a missing package.
`apk add openssh; rc-update add sshd default; rc-service sshd start`.

## 3. Provision

```sh
ssh root@<IMPLEMENTER> 'sh -s -- --role implementer' < deploy/runner/provision
ssh root@<ARCHITECT>   'sh -s -- --role arch'        < deploy/runner/provision
```

Installs packages, Claude Code from the signed apk repository (verified against the published key
checksum), clones the launchpad, writes the OpenRC service and its `/etc/conf.d`, registers the
runlevel. It **refuses before mutating anything** if the role does not match the box.

There is no `supervisor` role — `provision` takes `implementer` or `arch` and refuses the rest rather
than guessing which identity rules apply. The supervisor is provisioned by hand until that closes,
and doing it by hand is how two mistakes were made on 2026-07-29: a hand-copied `claude` binary
instead of the signed package, then a box with no `claude` at all.

## 4. What `provision` does not do — four gaps, all measured

1. **It sets no git identity.** A fresh box commits as `root@<hostname>` with the machine's domain
   attached — Operator-private data in commit metadata, a live leak class here (`decisions/0014` and
   the incident behind it). Set it per role, to the bot identity that seat authors as, **before the
   first commit exists on the box**.
2. **It installs neither `gh` nor `openssl`.** Every wrapper needs both; `openssl` is absent from
   minimal Alpine and RS256 signing cannot proceed without it. `apk add github-cli openssl`.
3. **It clones the private layer with the retired bot identity** — a username and token file that
   stop existing once the implementer identity is an App. On an App-only box the layer never
   arrives and `preflight` then refuses for a second, confusing reason. Clone it with the App
   credential, and **persist the helper with `git config`, never `git -c`**: `preflight` refuses a
   layer that cannot fetch, because *present is not fresh* and a frozen privacy gate reports `clean`
   exactly like a current one.
4. **It does not chmod the pattern files.** They are a list **of** the sensitive strings; they must
   be `600`, and a fresh clone will not be.

## 5. Credentials, and what each box must not hold

| box | holds | must NOT hold |
| --- | --- | --- |
| implementer | coder App key (`600`) + its app-id | reviewer key, architect token |
| architect | reviewer App key + app-id, architect token (all `600`) | any implementer credential |
| supervisor | nothing | everything |

Secrets reach a box over **ssh stdin only** — never argv, which is world-readable in `/proc` and
lands in shell history:

```sh
ssh root@<BOX> 'install -m600 -D /dev/stdin ~/.config/quince/<name>' < <local-file>
```

A retired credential is **not** copied onto a new box. Where a decision requires the record be kept,
it is kept on the box that already has it; a dead credential has no reason to spread.

## 6. The last mile — Operator-only, and it cannot be automated

```sh
ssh root@<BOX> -t 'claude auth login'    # a setup-token CANNOT establish Remote Control
cd /root/quince && claude                # once, to accept workspace trust
/config                                  # enable the push notifications the loop depends on
rc-service <SERVICE> start
```

`provision` says this itself and stops there. Batch the logins across boxes while a recent session is
warm — done separately, each is a fresh magic-link ceremony.

## 7. Verify a rebuilt box

```sh
QUINCE_RUNNER_ROLE=<ROLE> sh deploy/runner/preflight    # must end: environment is fit to start
<wrapper> api installation/repositories --jq .total_count
make privacy-check REF=origin/main...HEAD
```

**Read what the privacy gate swept, not just its exit code.** `0` answers *did anything match*; only
the trailing coverage list and pattern count answer *was anything looked at*. A box whose private
layer is stale reports `clean` identically to a current one — compare the pattern count against
another box before trusting it.

Then check the boundary **from the other side**, which is the assertion most likely to rot: place the
*other* role's credential beside the box, confirm `preflight` refuses, remove it, confirm it passes.
A boundary check never seen to fail is not known to work.

## 8. If your host is Proxmox — the scripts we use

Optional. Nothing above needs this; it is how the Operator's fleet is made.

**VMID convention:** `200+` templates, `100–199` runnable.

The template factory (`make-nerdctl-template.sh`) is Operator-local, not in this repo — a second host
will not have it, so copy it from the first. It needs an Alpine base tarball in the cache **at the
same version the other hosts use**, or the fleet runs two Alpines and behaviour diverges silently:

```sh
pveam update && pveam download local alpine-<VERSION>-default_<DATE>_amd64.tar.xz
```

Its defaults are those of whichever host it was written on. **Two will be wrong on a second host and
neither fails loudly** — a wrong gateway yields a container with no route, a wrong timezone yields
log timestamps that silently disagree across the fleet:

```sh
WITH_BUILDKIT=1 IP=<TEMPLATE_IP>/24 GATEWAY=<GATEWAY> TZ_NAME=<TZ> \
  ./make-nerdctl-template.sh <TEMPLATE_VMID> alpine-<VERSION>-nerdctl-buildkit \
  local:vztmpl/alpine-<VERSION>-default_<DATE>_amd64.tar.xz
```

`WITH_BUILDKIT=1` matters: the implementer runs `make image`.

**Full clones, never linked** (Operator ruling — linked clones pin the template forever through the
ZFS origin chain, so it can never be retired). Verify rather than trust:

```sh
pct clone <TEMPLATE_VMID> <VMID> --full 1 --hostname <NAME>
pct set <VMID> --cores <N> --memory <MB> --swap 0 --onboot 1 --searchdomain <DOMAIN> \
  --tags "quince-persistent;quince-role-<ROLE>" \
  --net0 name=eth0,bridge=vmbr0,gw=<GATEWAY>,ip=<IP>/24,type=veth
pct start <VMID>

zfs list -o name,origin | grep subvol-<VMID>     # a full clone shows  origin: -
```

Two Proxmox-specific traps:

- **`/root/.ssh` does not exist on a fresh clone.** Create it `700` and place the key with
  `pct push` at mode `600`. Pushing it through a `pct exec` shell instead loses the value to
  quoting — silently, producing an empty `authorized_keys` that looks placed.
- **Set the search domain with `pct set --searchdomain`, never by editing `/etc/resolv.conf`.**
  Proxmox owns the `# --- BEGIN PVE ---` block in that file and rewrites it on boot, so a hand edit
  survives exactly until the next reboot.

If a local resolver serves the boxes' names, it needs both halves: a record per box, **and** its
upstream resolver actually routing that domain to whatever serves it. An entry nothing forwards to
is as invisible as no entry.

## 9. Where the concrete values live

`local/environment.md` — Operator-local, gitignored, present only on the Operator's machines. Hosts,
VMIDs, addresses, sizing, per-site conventions. Public documents may reference it **by path** and
must never quote its contents.
