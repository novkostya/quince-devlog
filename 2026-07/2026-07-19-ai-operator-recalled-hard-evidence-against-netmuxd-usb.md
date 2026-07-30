# 2026-07-19 — (ai) Operator recalled hard evidence against netmuxd-USB

(ai) **Operator recalled hard evidence against netmuxd-USB** — an initial
USB backup through netmuxd died with a "packet too big"-style error at the 64 MiB
boundary + 1 byte (hardcoded-guard signature; unreported in netmuxd's tracker as of
today; observed version unknown). Ruling amended: **default USB topology = usbmuxd,
netmuxd serves Wi-Fi** until qn.2's netmuxd-USB audition (presence + fresh pairing +
a >64 MiB transfer on pinned v0.4.3) passes clean, whereupon the default flips to
single-muxer; a reproduction gets filed upstream with the signature, with a
patched-pinned-build option (the qn.7 libimobiledevice pattern). N-socket client
design makes the flip config-only either way.
