# 0013 — Network-level mitigation for Wi-Fi roaming is a workaround, never the primary answer

**Status:** live · **Ruled:** 2026-07-25 · **By:** implementer + Operator, live during lab legs; ratified by the architect
**Source:** `progress.md` entry `(dm)`, ratified at `(dn)` · **Canon:** PARTIAL

## The decision

An in-flight `mobilebackup2` session **cannot be rescued across a network roam at any layer** —
the TLS state is bound to the dead connection and there is no session reattach. Therefore:

- *"survive a roam"* is **off the table** as a goal; auto-retry-on-reconnect plus resume of the
  on-disk snapshot is the only path;
- **network-level mitigation** — AP or band steering, SSID separation, roaming-threshold tuning —
  is documented as a **workaround**, never as the primary answer.

## Why

The first half is a protocol floor, not an engineering budget: no amount of work at quince's
layer changes it, so a rung that promises roam survival is mis-scoped by construction.

The second half exists because the workaround **works**, which is exactly what makes it
dangerous. A user whose roaming is tuned away stops seeing the failure, and the product's real
answer — resume — never gets built or exercised. Recording the status keeps a mitigation from
being mistaken for a fix by the next person who finds it effective.

## Where it is enforced

**Half of it.** `roadmap.md:440-444` states the protocol floor as canon, in the ruling's own
terms, and names roaming as the root cause. **The workaround's status is stated nowhere** —
searched for `workaround`, `network-level`, `SSID`, `band`, `roam` across canon; the only
`workaround` hit is about the ZFS symlink dance.

So today nothing stops a future rung from treating AP tuning as the answer, which is the precise
outcome the second half was ruled to prevent.

**Owed:** one clause beside the protocol floor in `roadmap.md`, and it belongs in `qn.7`'s spec
when that rung is written.
