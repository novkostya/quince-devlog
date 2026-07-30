# 2026-07-27 — Two boxes measured the same property of the forge and disagreed by 4×, and one of the numbers moved while it was being reviewed

**Two boxes measured the same property of the forge and disagreed by 4×, and one of the
numbers moved while it was being reviewed.**
[quince#72](https://github.com/novkostya/quince/issues/72) closed by
[quince#98](https://github.com/novkostya/quince/pull/98) (`d9b42ec`). The typed event and the
`updated` backstop describe the **same act**, and the help text — where a consumer looks — said
nothing about how they arrive. Ruled with a sharpening: *may* is too weak, so it says a consumer
**must not rely on either ordering**, recorded as a property of **the forge** rather than of this
tool — *GitHub's PR fields do not move atomically, and anything reading two of them and inferring
an order is reading a race.* **What the unit added was the measurement, and then the measurement
taught the lesson twice.** The runner counted 11-of-12 same-tick; that went into canon as *the*
rate, and review supplied the other box's figure by the same method: **8-of-12, a 4× different
split rate**. A consumer would have read ~8%, planned for it, and been wrong by four times on the
box where a reviewer's own code runs. **That is quince#69's lesson — a measurement carries the box
it was taken on — committed by the session that had written that sentence into a journal entry
hours earlier, in an entry citing quince#69, which exists because the same mistake was made on the
same pair of boxes.** Knowing a failure mode by name did not protect against it; what did was
structural — the other box had the missing number and this one did not, so it could only have been
caught there. Then it happened again in the other direction: the architect figure **moved from
8-of-12 to 9-of-13 while the paragraph about it was under review**, because reviewing the change
was itself a review delivery and landed same-tick. Canon nearly shipped a figure its own source had
publicly withdrawn forty-five seconds before the push. So both figures are now **timestamped to the
minute rather than dated** — `2026-07-27` is a day and this moved inside one — and **the spread is
stated as the finding rather than either ratio**, with *do not average these*. A **bias present in
both and in neither's favour** is recorded too: these count deliveries a watcher was **alive to
observe**, and both boxes had unwatched windows, so both denominators are of observed acts rather
than of acts — a caveat that does not shrink with more samples, because it is a property of how the
sample is drawn. **The candidate mechanism was deliberately kept out of canon** and recorded on the
issue with its falsifiable prediction: the reviewer's hypothesis is that the split rate tracks *the
observer's temporal relationship to the act*, since on their box the observer is the actor. Canon
asserting an unconfirmed mechanism is what this same session declined on quince#62 item 5, and
doing the opposite the same day in the same tool would have made both decisions arbitrary. **No
fixture, and none is possible:** the ordering is observed across watcher *generations*, which the
pure fixtures cannot express, and a loop fixture staging two payloads would assert the stub's
script rather than the forge's behaviour — declared as debt rather than dressed in a test that
proves nothing.
([quince#98](https://github.com/novkostya/quince/pull/98),
[#72](https://github.com/novkostya/quince/issues/72),
[#69](https://github.com/novkostya/quince/issues/69),
[#62](https://github.com/novkostya/quince/issues/62))
