# Deliberately-failing fixture (zipline#109): a [nodes.X] provider carrying an
# authored ["zpr.addr", ...] pin must fail to compile. A node's static address
# is set by zpr_address, never by a provider pin (zipline#106).
# Named bad-* so the must-compile sweeps skip it.

define web as a service.

allow redhead users to access web.
