# 2026-08-07 — the split was the artifact, not the tool

**Retiring `bin/gh-arch` touched 26 files, and the substitutions were the boring part. Four skills
carried a READ/WRITE SPLIT that existed only because the architect seat held two credentials, and
one credential deleted it rather than reassigning it.** quince#676, built as quince#688, #689, #690.

Reads went through `gh-arch`, writes through `gh-review`, because approving or commenting through
the PAT re-created quince#47 *invisibly, because the output looks identical*. That rule generated
prose everywhere: a table in `/land` §0, a warning in `/review-pr` §0, a paragraph in `/retire`
insisting §1's read wrapper and §2's write wrapper were different tools, and one-line reminders at
each of the three places the two commands sat adjacent.

**None of it was wrong. All of it was scaffolding for a distinction that no longer exists**, and the
class of error it guarded can no longer be committed on that seat. Under the Operator's
guard-versus-archaeology ruling (quince#595) that makes it deletable: a reader who never knew the old
state needs none of it to avoid a mistake.

`/onboard` was the one that **inverted** rather than substituted. Its wrapper probe said `gh-review`
was *"deliberately absent: it is the verdict path, not a read path, and /onboard must never reach for
it"* — true while `gh-arch` did the reading, and now exactly backwards: skipping it leaves the
architect box with no probe that can succeed, so the cold-start skill would report *"no forge
credential"* about a box holding one.

**The rule that did most of the work is that a CREDENTIAL outlives its WRAPPER.** `bin/gh-arch` is a
tool; `quince-arch.token` is a file that can still be sitting on a box. So every check asserting
*this credential must not be here* is untouched — three wrappers still refuse beside it,
`provision`'s diagnostic still reports a helper that mentions it, and `forge-watch` still reads that
token as *this is an architect box*.

**I deleted that last one and the test blamed something else.** `forge-watch-actor-test` reported
*"architect woke on its OWN comment on a declared issue — quince#307 is not fixed"*. The cause was
`owed_role=none`, which fails both self-caused suppression arms open — so removing one line of role
detection presented as a regression in a feature two steps away. The file argues for keeping exactly
that shape one arm below, for `quince-bot`, and I had read that paragraph while editing beside it.

**What a deletion costs a test suite is worth writing down where the suite lives.** `wrapper-boundary-test`
went 69 → 56 and `provision-guard-test` 28 → 26, and one of those four lost cases is not
replaceable: it proved the private-layer username *follows the wrapper* rather than being hardcoded,
by placing a working PAT and expecting a non-App username. With only Apps left, no fixture reachable
through the public path can produce one. So the code arm it guarded is now unreachable **and**
untested — kept anyway, so the next PAT-shaped wrapper cannot silently inherit `x-access-token`, with
both halves of that stated at both sites.

**And one thing was filed rather than fixed.** `preflight` declines to refuse an architect box with
no reviewer key, on the reasoning that *"gh-arch still works"*. It does not; that box now has no forge
credential at all. The message was corrected and the verdict left alone, because turning a note into a
refusal is a boot-blocking decision and this was a sweep.
