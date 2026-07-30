# 2026-07-19 — (ad) public/private doc split

(ad) **public/private doc split** (Operator-spotted: the dev-env edit was
about to push homelab internals to the public repo): `local/` (gitignored) now holds
all Operator-specific facts — hosts, LAN addresses, container sizing, lab details;
public canon states rules generically and references `local/environment.md` by path
only. Personal identifiers scrubbed from public docs (example device names, private
design-system paths). Standing rule: hostnames, IPs, topology, and hardware specifics
never enter committed files.
