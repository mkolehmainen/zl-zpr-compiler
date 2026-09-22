# Deliberately-failing fixture (zipline#76, PR #8 review): the companion
# .zplc pins a ca_cert_path whose PEM body is truncated. Named bad-* so the
# must-compile sweeps skip it.

define Web as a service.

allow contractor users to access Web.
