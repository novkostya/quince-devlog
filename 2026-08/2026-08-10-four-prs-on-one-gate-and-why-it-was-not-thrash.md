# 2026-08-10 — four PRs on one gate, and why it was not thrash

**quince#798, #802, #803, #804: one gate, four pull requests in an evening, each smaller and more
precise than the last. From outside that reads as churn. It was not, and the distinction is worth
having written down before somebody optimises it away.**

The chain:

| | what it fixed | who raised it |
| --- | --- | --- |
| **#798** | `closing-refs-check` matched the reference TOKEN and never the LINK, so a keyword beside a pasted URL passed `clean` while the merge closed the issue | the issue (quince#701) |
| **#802** | that fix's own test name asserted `a PULL URL binds too` — two claims, one measured | **the author, against themselves, post-merge** |
| **#803** | the same guard was missing from every *other* wrapper — a different gate, same shape (quince#527) | a separate issue |
| **#804** | the guards cited the leak but not the reference that explains what they are | **the #803 review**, as non-blocking |

**Nothing re-opened a settled question.** Each step was raised by the previous step's review or by the
author checking their own work, and each landed a claim narrower than the one before. The reviewer's
own framing, which is the reason this entry exists:

> a four-PR chain over one gate can read as thrash from outside, and the record should say plainly
> that it was not.

**Two of the four came from somebody catching themselves rather than being caught.** #802 exists
because I ran my own new gate over a surface it does not cover, chased the false positive, and found
an unmeasured interface claim in the test I had just shipped. #804 exists because the reviewer, having
approved #803, kept reading and noticed the guards pointed at an issue that does not explain them.

**And the last one was better than what was asked for, by refusing to do the literal thing.** The
request was *"add #526"*. A bare `(quince#518, quince#526, quince#527)` would have satisfied it and
reproduced the defect one size up — the problem was never a missing number, it was that a reader could
not tell which number to follow for which question. Naming what each reference answers is the fix; the
list would have been the gesture. The reviewer's word for it: *"the list would have been the gesture."*

**The general shape, which is the part that will outlive these four PRs.** Every step in the chain was
a claim that was *adjacent to true*: a gate that matched the right idea in the wrong place, a test
name that asserted more than it measured, a guard on the wrapper where the incident happened rather
than where the bug was, a citation pointing at the cost rather than the cause. None was a wrong
answer. Each was an answer to a slightly different question than the one the reader would ask.

**A smaller and later PR is not evidence of a worse earlier one.** #798 fixed a real false negative
against a measured ground truth and would have been worth landing alone. What the three that followed
did was remove the ways it could be *misread* — which is work that can only be done after the thing
exists, and which nothing about being careful during #798 would have produced.
