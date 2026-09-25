# Deliberately-failing fixture (zipline#109): a [services.X] provider carrying
# an authored ["zpr.addr", ...] pin must fail to compile. Static adapter
# addresses come from a trusted service vending device.zpr_addr (zipline#106).
# Named bad-* so the must-compile sweeps skip it.

define web as a service.

allow redhead users to access web.
