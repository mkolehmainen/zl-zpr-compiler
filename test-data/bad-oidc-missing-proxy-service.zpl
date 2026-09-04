# Deliberately-failing fixture (zipline#6): an api="oidc" trusted service
# whose `service` names a fabric service that is not declared in [services].
# Named bad-* so the must-compile sweeps skip it.

define Webby as a service.

allow domain:'example.com' users to access Webby.
