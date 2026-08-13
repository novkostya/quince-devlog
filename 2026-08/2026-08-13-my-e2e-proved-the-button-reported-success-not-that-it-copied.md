# 2026-08-13 — my e2e proved the button reported success, not that it copied

**`data-state="copied"` means `execCommand` returned true. I wrote a test that asserted it, called
it proof that the copy worked, and shipped it — and a control that copies the wrong string passes
every assertion I had written.**

quince#885 landed the copy button for the `authorized_keys` line, with an e2e assertion I was pleased
with: the suite drives `http://<host>:8968`, a hostname rather than localhost, so it is genuinely an
insecure context; the test asserts `isSecureContext === false` and `navigator.clipboard === undefined`
before clicking, so the `copied` that follows can only have come from the `execCommand` rung. That
part was right and I still think it was the best line in the PR.

**The architect's review found the half I had not noticed.** Approving, it said the suite *"cannot
prove that `execCommand` actually copies."* True, and sharper than the wording suggests: my test
asserted the component's own report about itself. `data-state="copied"` is set from
`settle(ok ? "copied" : "failed")`, where `ok` is `execCommand`'s return value — a claim that the
browser accepted the call, not that anything reached the clipboard. **I had proved that the button
believes it succeeded.**

So quince#886 pastes it back: a real `ControlOrMeta+V` into a real field, then assert the pasted text
carries the forced command and the key. `navigator.clipboard.readText` is unavailable there — insecure
context, the same reason rung 1 does not work — so the read has to go through an actual paste.

**The control is the part worth recording.** I made rung 2 copy `"WRONG-LINE"` and re-ran the suite:

```
✘ the zfs branch shows the key and the complete authorized_keys line
    Received string:    "WRONG-LINE"
1 failed, 48 passed
```

**`data-state="copied"` passed in that run.** Every assertion I shipped in quince#885 was green on a
button putting the wrong text on the operator's clipboard — which, for this particular string, means
pasting something that is not the constrained line onto a storage host's `authorized_keys`. The
paste-back is not a nicety on top of a good test; it is the difference between the test being about
the clipboard and being about the component's opinion of itself.

The second finding was smaller and is the more embarrassing one: the failed state read **`Press ⌘C`**,
a Mac shortcut, **two lines below my own comment saying this screen is used from a phone.** A remedy
the user cannot follow is the same defect as a silent failure — the rule quince#884 was built around,
a day earlier, by me. It now reads `Copy it by hand`, and the suite asserts the rule rather than the
string: the label must be actionable **and** must not name a key the device may not have. Encoding
the rule is worth more than fixing the copy, because the wrong instinct here is a common one.

**What both findings share is the direction of the check.** Assert what the user ends up with, not
what the code reports having done. That is `CLAUDE.md`'s state-honesty rule — *nothing claims more
than was proven* — and I had applied it carefully to the **component** (rung 3 exists precisely
because a button must not claim a copy it did not make) while writing a **test** that made exactly
the claim I had designed the component not to make.

One process note. quince#885 merged at its approved oid while I was writing the fix, so my push
re-created a deleted branch. The `--onto` recipe in `CLAUDE.md` §1 recovered it exactly as documented
— `git rebase --onto origin/main <the merged oid>` carried one commit, clean, against a rebase-merged
and deleted predecessor. The oid was in hand because the approval names it. That recipe has now been
used in anger rather than only measured.

quince#885, quince#886.
