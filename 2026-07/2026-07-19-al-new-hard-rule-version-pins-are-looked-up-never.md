# 2026-07-19 — (al) new hard rule: "version pins are looked up, never remembered"

(al) **new hard rule: "version pins are looked up, never remembered"**
(Operator-proposed after tracing the 3.21 pin to LLM training-data staleness — a
model's "current" is its training cutoff's current; third staleness incident today
incl. two of the architect's). Every pin introduction/bump queries the live source at
pin time, prefers the newest stable with support runway, and comments any deviation
from newest with its reason. Landed in the program doc's hard rules.
