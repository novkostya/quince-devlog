# 2026-07-22 — (cm) Later idea banked: scoped per-device view + QR/link device enrollment

(cm) **Later idea banked: scoped per-device view + QR/link device enrollment.** Full
note in the roadmap Later/parked. An admin issues a **scoped token** (view/backup/restore-later) so
the *device owner* (not the admin) runs their own backups and browses their own data; onboarding via
a link/QR from the admin's device page that auto-authorizes the opening device. **Well-motivated,
not just convenience:** it is the delegated-access dimension qn.12's phone-first assisted model
assumes away (admin ≠ phone owner in a household) → natural home is after/with qn.12. **Security
notes banked now so a naive later build doesn't get it wrong:** the link carries a **one-time
short-TTL enrollment secret that mints a device-bound session, NOT a bearer token in the URL**;
**restore is a dangerous scope** (admin-only or re-auth even here); it is a real **auth subsystem**
(capability tokens, per-device sessions, enrollment, revocation UI, audit) that reopens the qn.1
security baseline. Later, not soon.
