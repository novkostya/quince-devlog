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

**Partially, and by accident.** `CLAUDE.md:249` protects the retired lettered ids *as citations*
— *"they stay forever as citations from docs and git history"* — but that is about identifiers,
not about the text. The words *annotate* and *never rewritten* appear in no canon file.

Until devlog#30, the rule was enforced by the substrate rather than by anyone reading it: the
journal lived in `progress.md`, behind branch protection, a required approval and linear history,
so a rewrite was a reviewed diff.

**This decision's importance changes with devlog#30 and should be read in that light.** Once the
journal is a set of Discussions, `updateDiscussion` and `deleteDiscussion` are one API call each
for the implementer, and **the forge records neither**. The rule stops being backed by anything
at exactly the moment it starts mattering.

**Owed:** a line in `CLAUDE.md`'s journal section — and it should land with, or before, the
migration. Tracked at devlog#69.
