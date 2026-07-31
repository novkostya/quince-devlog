# 0006 — A journal entry is annotated, never rewritten

**Status:** live · **Ruled:** 2026-07-26 · **By:** unattributed (stated inline in a correction)
**Source:** `progress.md` 2026-07-26 entry · **Canon:** PARTIAL

## The decision

A journal entry that turns out to be wrong is **annotated** — corrected in place by addition,
with the original left standing. It is never rewritten and never silently removed.

## Why

**A log that edits itself breaks the thing citations rest on.** This project cites journal
entries from canon, from issues and from PR threads; a citation is only worth anything if the
text it points at is the text that was there. An entry quietly corrected is worse than one left
wrong, because the correction destroys the evidence that anyone was ever misled.

## Where it is enforced

**By nothing, and that is the honest answer** — this line said "by the substrate" until quince#320
showed why that is an overclaim. `CLAUDE.md` protects the
retired lettered ids *as citations* — *"they stay forever as citations from docs and git history"* —
but that is about identifiers, not about the text. The words *annotate* and *never rewritten* still
appear in no canon file.

Until devlog#30, the rule rested on `progress.md` sitting behind branch protection, a required
approval and linear history, so a rewrite was a reviewed diff. **That is gone**: the journal is now
per-entry files on an unprotected `journal` branch, pushed with no pull request and no reviewer
(devlog#152).

**What replaced it is DIFFERENT, and weaker, and this paragraph has now been wrong in both
directions.** It first read: *"Once the journal is a set of Discussions, `updateDiscussion` and
`deleteDiscussion` are one API call each for the implementer, and the forge records neither. The
rule stops being backed by anything at exactly the moment it starts mattering."* That was true of
Discussions, and **the Discussions decision was reversed on 2026-07-30** for a reason that also
answers it: a suspended account's forge objects vanish while its commits survive — measured at 196
commits readable against 0 issues and PRs.

It was then rewritten — by me, hours later — to say the substrate is *"a better guarantee than the
reviewed diff it replaced."* **That is an overclaim, and quince#320 corrects the same sentence in
`CLAUDE.md`.** Recorded here rather than quietly patched, because this file's entire subject is a
record that acquires a different conclusion without showing it.

**Clone replication is EVIDENCE THAT MAY SURVIVE, not an integrity control.** A rewritten `journal`
branch *can* be contradicted by another copy — but only by one that is **current**, and **nothing
names which commit a journal clone holds.** `deploy/runner/preflight` asserts the private layer's
clone **can** fetch, deliberately not that it **has** (quince#121). A stale clone agrees with a
rewrite exactly as readily as a fresh one agrees with the truth.

**The precedent is the argument, and it runs the other way from what it looks like.** When this
project actually needed clone freshness to be *detectable* — quince#220, two boxes running materially
different privacy gates for hours with neither able to tell — replication did not supply it. Somebody
had to build a mechanism: quince#281 made `privacy-check` print `pattern source <commit> <date>`, so a
reader can see **which list** a sweep used. Currency became checkable for the pattern list because a
tool was written to check it, not because clones exist.

So against what it replaced — branch protection, a required approval, linear history, every edit in a
diff forever — this is **weaker**, and the rule rests on the discipline rather than on the substrate.
**The journal branch has no equivalent of quince#281**, and until it does, *"somebody might still hold
a copy that disagrees"* is the honest statement of its backing.

**Why the overclaim is worth more than the correction.** quince#318's own argument for moving the
journal to a branch was that a branch is the safer home. Leaving an inflated guarantee beside that
invites a future session to read clone-existence as a control and stop being careful — which is
exactly the failure this decision exists to prevent, arriving through the sentence meant to reassure.

**What is still owed, and it is LARGER than the previous version of this file claimed:** a line in
`CLAUDE.md`'s journal section saying an entry is annotated and never rewritten. The substrate makes
a rewrite *sometimes* detectable; it does not tell an agent not to attempt one, and it does not
reliably reveal one that happened. Tracked at devlog#69, and the annotation on the 2026-07-29 r2
retirement entry is the worked example of the rule being followed rather than described.
saying an entry is annotated and never rewritten. The substrate makes a rewrite *detectable*; it
does not tell an agent not to attempt one. Tracked at devlog#69, and the annotation on the 2026-07-29
r2 retirement entry is the worked example of the rule being followed rather than described.
