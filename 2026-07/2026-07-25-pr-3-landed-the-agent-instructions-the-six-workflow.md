# 2026-07-25 — pr.3 LANDED — the agent instructions, the six workflow skills, and the layered permission allowlist, as three bot-authored PRs reviewed and rebase-merged the same day

**pr.3 LANDED — the agent instructions, the six workflow skills, and the layered
permission allowlist, as three bot-authored PRs reviewed and rebase-merged the same day
([#7](https://github.com/novkostya/quince/pull/7) → `637bf06`,
[#8](https://github.com/novkostya/quince/pull/8) → `52adf48`+`b1d607c`,
[#6](https://github.com/novkostya/quince/pull/6) → `6df2461`; `main` linear,
`43136ec..6df2461`). This is the FIRST date-anchored entry: letters
are retired from here on** — `(a)`–`(do)` stay forever as citations, and new entries cite PR/issue
numbers, which GitHub allocates race-free. #6 rewrites `CLAUDE.md` into the standing instructions
(project shape; the forge-as-substrate workflow — fresh clone per unit of work, small PRs with one
reviewable claim, approver-never-author, the DoD; issue homes; the durable hard rules, now
including *interface facts and version pins are looked up live, never remembered*; the
resurrection test). #7 adds `/onboard` (the resurrection test as a command, and the only
model-invocable one, so "continue quince" self-onboards), `/kickoff`, `/report`, `/review-pr`
(with `all`), `/land`, and `/qa` — the last a labelled placeholder, since the ruled dev-container
deploy needs pr.2/pr.4 and inventing a deploy URL is exactly the lie state honesty forbids. #8
commits the generic allowlist plus the reference environment under convention names only
(`quince-pve`, `quince-dev-N`), with real addresses binding per-machine in the gitignored local
layer; denies mirror branch protection and keep credential-file contents out of transcripts. Two
self-corrections during the build, both from checking instead of remembering: the bot DOES have
push on this repo (R1's recorded one-repo scope had decayed once the devlog existed), and a
blanket force-push deny would have fought the routine amend-a-PR-branch flow. **The architect
review caught one blocking regression that the self-corrections did not**: #6's product-shape
summary described the pre-qn.5b reflink-*mirror* storage model and carried a stale `work/<job>`
path plus a "browse never reads the head" line that qn.5b falsified — written by summarising the
OLD `CLAUDE.md` instead of reading design §5, on the very rung whose thesis is that agents read
canon. Fixed against §5 as landed (one lifecycle; per-job `working/<udid>` seeded reflink→copy,
never hardlink; commit = verify → `renameat2(RENAME_EXCHANGE)` → snapshot/archive; `latest/` as
both offsite surface and the browse root of the newest version; dirty-working kept on failure;
seed sentinel; roll-forward) with an explicit §5 citation so the next editor is pointed at the
source, not the summary. Two rulings folded in during review: **`quince-bot` now has write on
quince-devlog** (journal entries are implementer output by design, so the journal is part of the
bot's workspace — `/report`'s access probe absorbs it with no skill change), and the
suggestion-turned-amendment steering runtime-equipped workstations to move the broad
docker/nerdctl grants into their local layer. Owed: a cleanup PR here stripping this repo's
program doc of the retired process loop (worktrees / rsync / commit-when-asked — `CLAUDE.md` wins
on process meanwhile), Operator-approved since it is architect-authored; the flake filed as
[quince#9](https://github.com/novkostya/quince/issues/9) (`TestStorySingleFlight` leaves its
second job running, so `t.TempDir` cleanup races a live writer — found by CI on a docs-only diff,
deliberately not fixed inside a process PR). Friction notes: nine items in
[devlog#1](https://github.com/novkostya/quince-devlog/issues/1) — token scope vs `gh pr edit`, the
decayed access record, the program-doc contradiction, a proposed DoD refinement naming the two
legitimate non-URL deploy outcomes, identity separation being discipline rather than structure
until pr.5, and the strict-checks + dismiss-stale-reviews tax that makes a stack of N sibling PRs
cost N re-approvals.
