# 2026-08-15 — A field became load-bearing and there was nothing to grep for

**`Test helper` composed `ssh -i /data/keys/zfs-` and had never worked since quince#1026 merged.**
The Operator found it by reading the command on screen: *"Identity file path in probe command seems
wrong."*

```
probe composes: [ssh -i /data/keys/zfs- -p 22 -o BatchMode=yes … root@localhost]
```

`/data/keys/zfs-` is quince#989's derivation applied to an **empty** dataset. The probe handler builds
a partial `config.ZFSConfig` from the request:

```go
zc := config.ZFSConfig{
    SSHUser: req.SSHUser, SSHHost: req.SSHHost,
    SSHPort: req.SSHPort, SSHKey: req.SSHKey,
}
```

quince#989 gave `SSHArgv` a new dependency — `key = ZFSKeyPathFor(z.ParentDataset)` — and this caller
was not updated.

## Why neither of us caught it, and the rule that follows

The architect's own account is the best statement of it:

> quince#989 made `ParentDataset` **newly load-bearing** for `SSHArgv` … I verified that **no stale
> `DefaultZFSKeyPath` reference survived anywhere**. That last check is the one that looks like it
> covers this and does not. *"Nothing still references the removed constant"* and *"every caller
> supplies the newly-required field"* are **different sweeps**, and I ran only the first.
>
> **When a change makes an existing field load-bearing, sweep the constructors of that struct, not
> the references to what was removed.** A field that was optional and becomes required has no removed
> symbol to grep for; the compiler is silent because the zero value is legal.

That is the whole thing. `handleStorageProbeHook` referenced no old constant — it built a struct that
was correct before the change and silently wrong after, and Go's zero value made it compile.

## The failure was maximally misleading

ssh finds no such identity file, offers nothing, and sshd answers **`Permission denied (publickey)`**
— a refusal *about the key* — on the one screen whose entire job is telling a wrong key from a wrong
forced command from an unreachable host. The remedy it points at is the one thing that was fine.

## And the gates could not see it, for the third time today in a third shape

The check's outcome is `unreachable` either way. Every gate here asserts the **outcome**; the thing
that was wrong was the **composed argv**, and nothing asserted that. The fix's test does — including
`strings.HasSuffix(k, "/zfs-")`, since `zfs-` is a name no dataset can produce, so its appearance is
unambiguous.

Same shape as the other two today: `TestCommitRefuses…`'s name asserting a branch its body never
reached, and quince#1033's `gates-ui` proving a rule while the layout was the defect. **The assertion
sitting one level away from the thing that breaks.**

## The second defect underneath, which is what made it fatal

Even with the parent supplied, the derived path is wrong **before the storage is added** — the key
the operator was shown and pasted is `.pending` until *Add* moves it (quince#1038).

And `Test helper` **gates the save**. A check that can never pass means **a new zfs storage cannot be
added at all**. So the two PRs approved that evening left the add-storage path unusable between them,
which is precisely what the Operator hit and reported as *"can't get it working"*.

`ZFSKeyInUse` resolves what the screen resolved — committed key if there is one, otherwise pending —
and **never generates**, because a press that quietly created key material would be quince#1038's
defect arriving through a second door.

## Walked, and this time the restore was proved

On a throwaway instance against the real ZFS host, no storage added:

```
Test helper BEFORE pasting the line → "outcome":"unreachable"
Test helper AFTER  pasting the line → "outcome":"ok"   "detail":"110592  64424398848"
```

The rig's `authorized_keys` was modified for the walk and restored — **verified byte-identical by
md5**, rather than assumed, which is exactly what I got wrong on quince#1026's walk earlier the same
day.

## One more of my own

I opened this PR without running `make gates-ui-e2e`, for the **second time today**. CI went red on
`story12-native-scroll`, which the architect classified against a control as quince#975's known flake
— my diff touches zero `ui/` files and `main` carries that spec green. So the red was not mine; the
habit still is. If it had been real, the Operator would have found it on the rig again.
