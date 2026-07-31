# 0013 — Network-level mitigation for Wi-Fi roaming is a workaround, never the primary answer

**Status:** live · **Ruled:** 2026-07-25 · **By:** implementer + Operator, live during lab legs; ratified by the architect
**Source:** `progress.md` entry `(dm)`, ratified at `(dn)` · **Canon:** PARTIAL — *roadmap half closed 2026-07-31, spec half still owed*

## The decision

An in-flight `mobilebackup2` session **cannot be rescued across a network roam at any layer** —
the TLS state is bound to the dead connection and there is no session reattach. Therefore:

- *"survive a roam"* is **off the table** as a goal; auto-retry-on-reconnect plus resume of the
  on-disk snapshot is the only path;
- **network-level mitigation** — AP or band steering, SSID separation, roaming-threshold tuning —
  is documented as a **workaround**, never as the primary answer.

> **Annotated 2026-07-31, not rewritten** ([quince#325](https://github.com/novkostya/quince/issues/325)).
> The first bullet's **floor** stands untouched — a roam is unsurvivable in-flight, still.
> Its **remedy** does not: the Operator ruled that **auto-retry is impossible**, because a retry
> inside iOS's recent-unlock window does not skip the passcode prompt. The honest words are
> **one-tap retry**, and `CLAUDE.md`'s flat *"no auto-retry"* therefore stands unqualified. The
> same ruling dropped the reliability work this bullet was pointing at; the answer is now `qn.12`
> (PWA + Web Push), which delivers the tap. Left in place so the citation still resolves to the
> text that was there.

## Why

The first half is a protocol floor, not an engineering budget: no amount of work at quince's
layer changes it, so a rung that promises roam survival is mis-scoped by construction.

The second half exists because the workaround **works**, which is exactly what makes it
dangerous. A user whose roaming is tuned away stops seeing the failure, and the product's real
answer — resume — never gets built or exercised. Recording the status keeps a mitigation from
being mistaken for a fix by the next person who finds it effective.

## Where it is enforced

**Both halves of the RULING, in one of the two places it was owed.** `roadmap.md`'s M4 states the
protocol floor in the ruling's own terms and names roaming as the root cause, and since 2026-07-31
the clause this file was owed sits beside it:

> **And network-level mitigation — AP or band steering, SSID separation, roaming-threshold tuning —
> is a WORKAROUND, never the primary answer**

**What this used to say, and why it is worth keeping visible.** *"The workaround's status is stated
nowhere"* — measured, by searching `workaround`, `network-level`, `SSID`, `band`, `roam` across
canon, where the only `workaround` hit was about the ZFS symlink dance. So for six days nothing
stopped a future rung from treating AP tuning as the answer, which is the precise outcome the
second half was ruled to prevent. The gap closed because the rung the clause was owed to came up
for a rewrite, not because anything watches for it.

**Still owed, and it is now the smaller half:** the clause belongs in `qn.7`'s spec too, when that
spec is written ([quince#325](https://github.com/novkostya/quince/issues/325) deliverable 2). A
roadmap section can be rewritten out from under a rule; a spec is the rung's contract.
