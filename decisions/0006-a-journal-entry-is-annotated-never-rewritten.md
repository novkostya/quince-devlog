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

**By the substrate, and that is the outcome rather than the plan.** `CLAUDE.md` protects the
retired lettered ids *as citations* — *"they stay forever as citations from docs and git history"* —
but that is about identifiers, not about the text. The words *annotate* and *never rewritten* still
appear in no canon file.

Until devlog#30, the rule rested on `progress.md` sitting behind branch protection, a required
approval and linear history, so a rewrite was a reviewed diff. **That is gone**: the journal is now
per-entry files on an unprotected `journal` branch, pushed with no pull request and no reviewer
(devlog#152).

**What replaced it is stronger than what it lost, and this paragraph used to say the opposite.** It
read: *"Once the journal is a set of Discussions, `updateDiscussion` and `deleteDiscussion` are one
API call each for the implementer, and the forge records neither. The rule stops being backed by
anything at exactly the moment it starts mattering."* That was true of Discussions and **the
Discussions decision was reversed on 2026-07-30**, in the same thread, for a reason that also
answers this: a suspended account's forge objects vanish while its commits survive — measured at 196
commits readable against 0 issues and PRs.

Distributed version control replicates the record. **A rewritten `journal` branch is contradicted by
every clone on every box**, and both session hosts hold one. Nobody has to enforce the rule, and
nobody has to notice a violation for it to be visible — which is a better guarantee than the
reviewed diff it replaced, because that one depended on a reader.

**What is still owed, and it is smaller than it was:** a line in `CLAUDE.md`'s journal section
saying an entry is annotated and never rewritten. The substrate makes a rewrite *detectable*; it
does not tell an agent not to attempt one. Tracked at devlog#69, and the annotation on the 2026-07-29
r2 retirement entry is the worked example of the rule being followed rather than described.
