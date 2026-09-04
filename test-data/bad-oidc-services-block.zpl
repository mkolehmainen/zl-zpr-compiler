# Deliberately-failing fixture (zipline#6): an api="oidc" trusted service
# with a stray [services.google-vs] block. Named bad-* so the must-compile
# sweeps skip it.

define Webby as a service.

allow domain:'example.com' users to access Webby.
