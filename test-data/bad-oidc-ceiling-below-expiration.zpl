# Deliberately-failing fixture (zipline#41): `max_auth_age_seconds` is
# non-zero but below `expiration_seconds` — a credential would outlive its
# own session ceiling. Named bad-* so the must-compile sweeps skip it.

define Webby as a service.

allow domain:'example.com' users to access Webby.
