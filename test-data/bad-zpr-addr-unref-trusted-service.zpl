# Deliberately-failing fixture (zipline#109 review round 1): companion ZPL for
# bad-zpr-addr-unref-trusted-service.zplc. The policy only uses attributes
# vouched for by the `attrfile` store; the `bas` trusted service in the .zplc
# is never consulted by weaving, and its provider carries the ["zpr.addr", ...]
# pin under test. Named bad-* so the must-compile sweeps skip it.

define web as a service.

allow redhead users to access web.
