# oidc + file trusted-service interplay fixture (zipline#23).
# The Background configuration from docs/plans/2026-09-14-trusted-service-interplay.md:
# `google` authenticates the user; `happyfile` adds attributes keyed on
# google's identity attribute (user.sub). The policy references only the
# file service's attribute, so the compiler must retain `google` by the
# identity-vendor rule, not by an attribute reference.

define Web as a service.

# `lazy` resolves through the happyfile trusted service (lazy -> #user.lazy).
allow lazy users to access Web.

# In policy you can define "administrators" in any way you want.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

# VisaService is a reserved name.
allow NetAdmins to access VisaService.
