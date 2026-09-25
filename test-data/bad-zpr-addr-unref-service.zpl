# Deliberately-failing fixture (zipline#109 review round 1): a [services.X]
# provider carrying an authored ["zpr.addr", ...] pin must fail to compile even
# when the ZPL never references that service, so weaving never selects it. The
# rejection must be eager, at config parse time (zipline#106).
# Named bad-* so the must-compile sweeps skip it.

define web as a service.

allow redhead users to access web.
