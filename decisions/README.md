# decisions

One file per decision, citable by path. **This directory is the missing `D<N>` for process.**

`docs/quince.stack.md` is already a decision-record ledger for technology — `D<N>`, one per
choice, each carrying the alternatives and why they lost. Process and governance had no
counterpart, which is why the devlog#30 inventory found **every** product ruling it tested
already stated in canon and five governance rulings stated nowhere at all.

## What goes here, and what does not

A ruling earns a file only if it is **(A) live** · **(B) load-bearing** · **(C) homeless** —
the criteria, the evidence, and the reasoning are in
[`0000-what-counts-as-a-decision.md`](0000-what-counts-as-a-decision.md).

**A file here is the record of a decision. It is not the enforcement of a rule.** `quince-devlog`
has no `CODEOWNERS` and no required checks, so a live rule must never have a file here as its
*only* statement — that would relocate governance from an owned file to an unowned one. Every
file therefore names where its rule is enforced, or names the canon gap as owed.

## The lifecycle

A decision file's relationship to canon is **expected to change**:

| canon status | what the file does |
| --- | --- |
| **ABSENT / PARTIAL** | states the ruling and its reasoning, and **names the canon gap as owed** |
| **STATED** | keeps the reasoning and the alternatives, and **points at canon** for the rule — it must stop restating it |

Every file below is currently ABSENT or PARTIAL, because criterion (C) admits nothing else at
creation. The STATED row is where they go as their gaps close, and closing a gap **is** the point
of naming it. Without that transition `decisions/` becomes a second copy of canon one gap-closure
at a time — arriving by exactly the drift the criteria exist to prevent.

## The decisions

| # | decision | canon |
| --- | --- | --- |
| [0000](0000-what-counts-as-a-decision.md) | What counts as a decision — the criteria and the inventory | *(report, not a decision)* |
| [0001](0001-the-gate-set-is-full.md) | The process gate set is full: the next addition must displace | ABSENT |
| [0002](0002-pr-title-refs-resolve-in-repo.md) | A bare `#N` in a PR title must resolve in-repo | ABSENT |
| [0003](0003-do-not-probe-branch-protection.md) | Do not probe whether the App can write branch protection | ABSENT |
| [0004](0004-a-mutation-must-be-verified-to-have-mutated.md) | A mutation must be verified to have changed the file | ABSENT |
| [0005](0005-preflight-runs-the-gates-own-validator.md) | `preflight` runs the gate's own validator, not a second predicate | ABSENT |
| [0006](0006-a-journal-entry-is-annotated-never-rewritten.md) | A journal entry is annotated, never rewritten | PARTIAL |
| [0007](0007-a-control-that-can-delete-itself.md) | A control that can be deleted to disable itself is not a control | PARTIAL |
| [0008](0008-lowering-the-floor-is-reviewed.md) | Lowering the pattern floor is reviewed by a non-author | PARTIAL |
| [0009](0009-reviewer-seat-skill-changes.md) | Reviewer-seat skill changes and the Operator — carries a `PROPOSED (gap)` | PARTIAL |
| [0010](0010-architect-rules-properties-implementer-measures-mechanisms.md) | The architect rules properties; the implementer measures mechanisms | PARTIAL |
| [0011](0011-pr6-root-path-is-a-forced-command-wrapper.md) | `pr.6`'s root path is a forced-command wrapper, never a general root key | PARTIAL |
| [0012](0012-repo-naming-policy.md) | `quince-*` for satellites, `ios-backup-*` for standalone libraries | PARTIAL |
| [0013](0013-network-mitigation-is-a-workaround.md) | Wi-Fi network mitigation is a workaround, never the primary answer | PARTIAL |

## What is deliberately not here

**The project's biggest decisions.** Never-mutate-a-committed-version, roll-forward, the ASSISTED
model, Wi-Fi as the primary use case — all live and all load-bearing, none here, because all are
already stated in canon. That is criterion (C) working as designed and it is the outcome most
likely to look wrong at a glance. The decisions log holds the rulings with nowhere else to live.

**Superseded rulings.** Six of the seven rulings in the clone-strategy chain are dead; history's
home is the Journal, not this directory. See `0000` §2.
