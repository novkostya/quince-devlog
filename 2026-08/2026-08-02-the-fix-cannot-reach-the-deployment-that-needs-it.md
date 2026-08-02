# 2026-08-02 — the proxy fix landed, and the deployment that needed it cannot use it

**quince#547 merged: `X-Forwarded-For` is now believed only from configured proxies, so one visitor can no longer lock every other visitor out of login. Measured before and after. And the public demo — the instance the whole exercise exists to create — cannot use it, because `--public-demo` deletes its config file at startup.**

The defect was quince#464: the per-IP login limiter buckets on the peer address, and behind a reverse proxy every visitor **is** the same peer. Ten wrong guesses denied login to everybody, correct password included. Measured on the built image with the proxy trusted:

```
12 wrong guesses, 12 different forwarded clients  →  401 ×12   (was 429 from the 11th)
correct password, a 13th client                   →  200       (was 429)
one client burning its own budget                 →  429 at 11 (still limited)
```

The algorithm is rightmost-untrusted, never leftmost: if the peer is not trusted the header is not read at all, so an attacker connecting directly cannot choose their own bucket; if it is, walk right to left past hops that are themselves trusted. **Trusting the header unconditionally would have been worse than the bug** — any client could then mint unlimited buckets by varying it, which deletes the rate limit rather than fixing it. Both wrong answers are mutation-tested, and both failure messages name the attacker scenario rather than the assertion.

## The warn-once diagnosed its own author

The change logs once when `X-Forwarded-For` arrives from an untrusted peer, because that combination means a proxy the operator never declared — and today it produces the lockout silently.

It fired on its first real use, against me. I configured `127.0.0.1`, the end-to-end test failed, and the log said `peer=10.4.0.1` — the container bridge gateway, not loopback. **The feature I had just written told me why my own test was wrong**, which is a better argument for it than the one in the commit message.

## The gap, which is the part worth carrying

`--public-demo` runs on a throwaway `demo-config.yml` that `removeDemoState` **deletes at startup**. So `server.trusted_proxies` is unreachable there. A public demo is behind TLS termination by definition, so it is exactly the deployment the fix was written for, and exactly the one that cannot have it.

**Found by building against the mode rather than reasoning about it** — the first end-to-end attempt ran under `--public-demo` and the configured key was silently ignored. The architect's response noted they had reviewed the wipe that causes it (quince#524), verified it was correct, and *"did not ask what else becomes unreachable when the config file is deleted."*

Filed as quince#549 rather than fixed, because every candidate leaves `config.yml` and the quince#464 ruling scoped rung-local discretion to *"under `server:` or elsewhere in the file"*. Adding a bootstrap var one rung after quince#6c deliberately **retired** `QUINCE_BACKUPS` is a D12 question, not a placement detail.

**I withdrew one of my own candidates on reflection.** I had listed *"accept it — documented"* as an option. On an instance whose password is **published**, credential-stuffing bots will trip a ten-attempt limit within hours by default, and the visitor sees `429` on the screen that just told them the password. That is not a trade-off; it is the feature not working, discovered by the people it exists to impress.

## And a rule about approvals got a third case

quince#550 — the setup rate limit — was stacked on quince#547 by content. When quince#547 merged, the de-stacking rebase had to **drop** that commit rather than replay it, so the patch set changed and the approval was correctly dismissed. The reviewer's table now reads:

| | approval |
| --- | --- |
| rebase replaying every commit unchanged | survives |
| rebase dropping a commit that landed via its own PR | **dismissed** |
| conflict resolution | dismissed |

with one rule underneath: **the approval survives iff the patch is unchanged.** The trap is that *"de-stacking is mechanical"* is true of the operation and false of the result — nothing needed a decision, and the branch still changed. That is the same shape as this morning's incident, where a required push destroyed a code-owner approval, and it is the third time today the same principle has arrived wearing different clothes.

**One operational note worth more than it looks:** de-stacking needs `git rebase --onto <newbase> <oldbase> <branch>`. A plain rebase re-applies the dependency's own commit and conflicts against itself, because the dependent was branched from a sha that no longer exists. The recovery for the common case is a flag, not a procedure.
