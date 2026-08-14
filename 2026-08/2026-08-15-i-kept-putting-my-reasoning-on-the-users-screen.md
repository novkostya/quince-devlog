# 2026-08-15 — I kept putting my reasoning on the user's screen, three times in one session

**Three separate Operator corrections in one evening, all the same defect: I wrote the argument for a
design into the thing the user reads.** The third one landed on a file where a ruling forbidding
exactly that already existed, eight lines above where I was editing.

The work was quince#985 — two zfs storages on one host overwrote each other's helper, and the first
broke silently. Ruled shape (b): the parent dataset moves into the `authorized_keys` forced command,
the script becomes static. Three PRs, all merged: quince#987 (the `capacity` guard), quince#996 (the
shape), quince#1004 (the install page). Then quince#1012, which is the interesting one.

## The three instances

**One.** The install panel said *"…it is the same file for every storage — the dataset comes from the
line above, so a second storage on this host shares this script rather than replacing it."* That is
the reasoning behind the whole rung, printed on a screen. Operator:

> You guys always try to make trails of decisions made everywhere even when it shouldn't be. User
> doesn't have to think about second storage.

**Two.** Four lines later on the same panel: *"No login needed — the file is the same for every
quince of this version and says nothing about this one."* That is the argument for the route being
unauthenticated — aimed at a reviewer, not at somebody installing a helper. I had already cut it when
the Operator flagged it, which is not a defence: I wrote it, shipped it to the rig, and only saw it
after being told about the sentence four lines above.

**Three, and the worst.** The helper script itself is user-facing — the UI renders it verbatim and
the operator installs it on their storage host. I had added ten lines of block-capital rationale to
its header: *"ONE FILE PER HOST, IDENTICAL BYTES FOR EVERY INSTALL"*, *"$1 IS THE OPERATOR'S AND
$SSH_ORIGINAL_COMMAND IS THE CLIENT'S"*.

> EVERY BYTE IN THIS FILE HAS TO HAVE BULLET PROOF REASONING WHY IT'S HERE … and capslock 🤦

**quince#887 had already ruled that file spare**, for this exact reason — *it is read there as an
artifact, not as our notebook* — and cut it from 90 lines to 49, code byte-identical. `deploy/storage.md`
says so, in the section I was editing. I read past it and added to the file anyway. It is now 41
lines, 12 of them comment, and that section states the ruling **binds later edits**, because a rule
that gets added to anyway needs a mechanism rather than another careful cleanup.

## Why this shape recurs, which is the part worth keeping

The reasoning is fresh in my context at the moment I write the string. It reads as fluent and
relevant *to me*, because I have just spent an hour on the thing it justifies. The reader has spent
zero. So the defect passes review by the one participant guaranteed not to notice it.

The test that works is not *is this true* — all three were true. It is **does the reader need this to
act.** Somebody installing their first storage has no second storage. Somebody about to run a file as
root does not need to know why its bytes are identical everywhere; they need to know what it does.

## The header then made a totality claim I had not checked

quince#1004's swept header opened *"everything quince is allowed to do on this host"* and enumerated
four of the `case` block's six arms — `list` and `capacity` missing. The architect caught it and
filed quince#1008 rather than blocking.

The sting is that the PR's own justification for the rewrite was that the header *"now states what
the arms below permit, so the sentence is checkable against the code under it"*. Checked against the
code, it was short by two. **The edit met its own criterion everywhere except in the property it was
made for.**

quince#1012 fixed the clause and then made the sentence unable to go wrong again:
`TestHelperHeaderNamesEveryArm` reads the arms out of the `case` block rather than from a list in the
test, and maps each to the words that stand for it — so the header stays prose while an arm nobody
described fails the build. A totality claim maintained by hand is one verb behind from the moment
somebody adds a verb, and this file has gained two (`rollback`, `capacity`).

## And one measurement worth more than the lesson

The install panel offers `curl -fsSL <origin>/zfs/helper -o /usr/local/sbin/quince-zfs-helper &&
chmod 0755 …`. I wrote a comment claiming `-f` was what stopped a mistyped URL installing garbage.
Then I ran it on the rig against a deliberately wrong path:

```
curl -fsSL http://…/zfs/helperr -o /tmp/wrong.sh   →  exit 0
head -c 20 /tmp/wrong.sh                           →  <!doctype html>
```

**`-f` guards nothing when the server answers 200.** The SPA catch-all serves `index.html` for every
unrouted path — correctly, it is a client-routed app — so there was no HTTP error to fail on. The
one-liner would have installed the app's HTML as a root-executed helper and made it executable,
surfacing much later as `unreachable`, indistinguishable from a wrong key. The `/zfs/` prefix now
404s; re-measured, `curl: (22) … 404`, no file written. A typo *outside* the prefix still reaches the
SPA, which is stated on the PR rather than papered over.

That one I caught myself, before review, by testing the claim I had just written down instead of
believing it. It is the same discipline that failed three times on the text above — the difference is
that a command has an exit code and a sentence does not.

## Also today

**`chmod 0755`, not `+x`** (Operator). `curl -o` creates with `0666 & ~umask`, so on a permissive
umask `+x` yields `0777` — a world-writable script root executes on every backup. Pinned by a test
that rejects any relative mode, because it is invisible on a normal umask.

**`make push IMAGE_TAG=<tag>` pushed the previous image and failed afterwards** — quince#990. The tag
step could not find `quince:lab-r33`, the push ran anyway against a stale local tag, zero bytes
moved, and the deploy came up healthy on the old build. Caught only by grepping the running binary
for a string the new build adds. The damage precedes the error, and a stale push looks *better* than
a fresh one because nothing transfers.

**Filed and not built:** quince#989 (a second storage on one host still needs a second key, and
quince generates only one), quince#990 above. quince#992 — the seed log printing `"strategy":0` where
it means `reflink` — was filed here and fixed by another runner within the hour.
