# 2026-08-15 — Every test passed and the design was unusable

**The ruling on quince#989 named `%` as the separator for derived key paths. `%` does not work:
OpenSSH percent-expands `IdentityFile`, so `ssh -i /data/keys/zfs-labpool%quince` dies parsing its
own argument and never reaches the network.** Six unit tests passed under it. Only the rig found it.

```
vdollar_percent_expand: unknown key %q
percent_dollar_expand: failed
```

The same key copied to a `+` path, same host, same command: `4060418048  124788600832`.

## What the tests were asserting, and why all of them were true

The derivation had to turn a parent dataset into one filename. The properties I gated were the ones
the ruling argued about, and every one of them held:

- **injective** — `tank/a-b/c` and `tank/a/b-c` derive different paths, which a `/` → `-` scheme does
  not;
- **traversal-proof** — `datasetPattern` accepts `tank/../../etc` (only a *leading* `..` is blocked),
  and escaping removes every separator, so it cannot name a file outside the key directory;
- **one component**, **stable across calls**, **`ssh_key` still wins**, **two parents → two keys**.

All true. All beside the point. **The property that mattered was whether the path could be opened by
the one program that consumes it**, and nothing in the package knows that `ssh` reads its `-i`
argument through a percent-expander. This is the *right answer, wrong reason* class in its purest
form, and quince#989's ruling had said in as many words to walk it rather than infer it.

`%%` escapes it and is worse: the escaped form is what an operator would have to type, and `ssh_key`
in `config.yml` is **not** percent-expanded — so the file and the flag would disagree about which
path they mean. A fix that works in one of two places. `+` is named by the same ruling, is equally
outside `datasetPattern`, and needs no escaping anywhere.

`TestZFSKeyPathIsSafeForSSHIdentityFile` now pins it, so the next reader cannot re-pick `%` from the
ruling's own text.

## The bug underneath, which the issue understated

I filed quince#989 as *quince cannot make the second key, so the operator makes it by hand*. The
architect's ruling corrected the framing, and it is worth keeping because the symptom pointed
somewhere else entirely.

`EnsureZFSKey` discovers before it generates — the property that stops it overwriting a key whose
public half is already installed on a host quince cannot see. With **one path for every storage**,
asked about a second storage's dataset, it found the **first** key and rendered a line pairing key A
with dataset B. sshd stops at the first line whose key matches, so that line is inert and storage B
stays confined to dataset A.

**And it reads healthy.** `capacity` takes no argument and answers for whatever `$PARENT` the live
forced command names, so *Test helper* returns dataset A's free space for storage B and both
read-only probes pass. Only `create` fails, at commit, after a transfer.

Walked on the rig with two keys quince's own endpoint generated:

```
key for labpool/quince    capacity → 4060418048  124788600832   list quince2 → refused
key for labpool/quince2   capacity →     110592   64424398848   list quince  → refused
```

**Two capacity answers from one binary is the whole proof** — 124 GB and 64 GB, because each key's
forced command names a different parent. Under the old shape the second would have been the first's.

## I broke the rig cleaning up, and the shape of that is worth more than the minute it cost

The walk mutates a shared host: it appends `authorized_keys` lines and installs keys. I took a backup
before appending and restored from it afterwards — except the backup was taken **during** the walk
rather than before it, so it captured a state already missing the Operator's `-lz4` and `-nocap`
helper lines. The restore dropped them. The lab's zfs storage refused for about a minute until I
rebuilt the file from a pre-session backup and verified it by driving the real transport again.

**I proved the forward direction carefully and treated the rollback as bookkeeping.** Every step
going in was measured; the step coming out was assumed. On a host that is not mine, the restore
deserves the same standard as the experiment — and the check is cheap: compare the restored file
against what was there, rather than trusting that a `cp` from a file named `.bak` means the right
thing.

Two smaller instances of the same habit landed the same day: I deployed the new build to the lab and
left its own storage broken, because the derivation moved where quince looks for the key and I had
verified the transport **by hand at the old path** rather than through quince. `reachable: true` in
the daemon's own startup log is the check; `ssh` working from a shell is not.

## Also today

**quince#992 was already fixed and I nearly rebuilt it.** I had proposed `.String()` at the call
site; what landed was `LogValue()` on the type, which is better — slog resolves a `LogValuer` before
the handler, so it is right for the text handler too, where a `MarshalText` would fix only JSON. My
first check looked at the call site, saw it unchanged, and concluded the fix was not in. **The honest
check is the record, not the argument list** — and the commit's own comment said so.

**quince#966 was fixed and left open** for the same reason its PR carried `Refs` rather than a
closing keyword. Both closed with the evidence rather than on the strength of a commit subject.
