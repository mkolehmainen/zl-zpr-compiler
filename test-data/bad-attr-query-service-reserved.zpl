# Deliberately-failing fixture (zipline#76): a zpr-attr/1 trusted service
# declaring the reserved `service` property. Named bad-* so the must-compile
# sweeps skip it.

define Web as a service.

allow contractor users to access Web.
