# api = "oidc" trusted service fixture (zipline#6).
# Derived from test-file.zpl with the BAS-dependent statements removed:
# the only declared trusted service is the off-net OIDC provider `google`,
# so every attribute here resolves through it or the default service.

define Webby as a service.

# `domain` resolves through the google trusted service (hd -> user.domain).
allow domain:'example.com' users to access Webby.

# In policy you can define "administrators" in any way you want.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

# VisaService is a reserved name.
allow NetAdmins to access VisaService.
