# Deliberately-failing fixture (zipline#41): `allow_offline_access = true`
# without `max_auth_age_seconds` (the session ceiling).
# Named bad-* so the must-compile sweeps skip it.

define Webby as a service.

allow domain:'example.com' users to access Webby.
