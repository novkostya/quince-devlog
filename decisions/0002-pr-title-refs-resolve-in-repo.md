# 0002 — A bare `#N` in a PR title must resolve in the repository the PR is in

**Status:** live · **Ruled:** 2026-07-27 · **By:** architect
**Source:** `progress.md` 2026-07-27 entry · **Canon:** ABSENT — enforced by a lint, stated nowhere

## The decision

Every bare `#N` reference in a PR title must resolve in the repository the PR is opened against.
A reference to another repository is written `owner/name#n`.

Related, ruled in the same pass: **never interpolate the title into the recipe text** — the
`TITLE=` variable was deleted rather than repaired, and `gates-sh` bans `$(TITLE)`.

## Why

Issue numbers collide across `quince` and `quince-devlog`. A bare `#141` in a devlog PR title
renders as a link to the devlog's `#141`, which is a different thing entirely — so the citation
does not merely fail, it silently points somewhere plausible and wrong.

Two rulings shaped this and **the second reversed the first**: an initial scoping ruling was
overturned by resolution-based scoping, which is the version that landed.

## Where it is enforced

A lint (`bin/pr-title-refs`, wired into CI). **The rule itself is stated in no canon file** —
searched for `PR title`, `#N`, `cross-repo`, `owner/name#`. The only repo-qualification rule in
canon is `forge-watch`'s `--all` issue syntax, which is a different subject.

**Owed:** one line in `CLAUDE.md`'s journal/PR conventions. A rule enforced only by a check is a
rule nobody can read before tripping it.
