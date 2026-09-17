# api = "oidc" trusted service with offline access (zipline#41).
# Derived from test-oidc.zpl: `allow_offline_access = true` paired with a
# `max_auth_age_seconds` session ceiling above `expiration_seconds`.
# Named test-* so can_compile_misc_test_policies sweeps it — it MUST compile.

define Webby as a service.

# `domain` resolves through the google trusted service (hd -> user.domain).
allow domain:'example.com' users to access Webby.

# In policy you can define "administrators" in any way you want.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

# VisaService is a reserved name.
allow NetAdmins to access VisaService.
