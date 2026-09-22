# oidc + zpr-attr/1 trusted-service interplay fixture (zipline#76), on the
# oidc-file-interplay pattern (zipline#23): `google` authenticates the user;
# the `zipline` attribute service decorates with attributes keyed on google's
# identity attribute (user.sub). The policy references only the attribute
# service's attribute, so the compiler must retain `google` by the
# identity-vendor rule, not by an attribute reference.

define Web as a service.

# `contractor` resolves through the zipline attribute service
# (contractor -> #user.contractor).
allow contractor users to access Web.

# In policy you can define "administrators" in any way you want.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

# VisaService is a reserved name.
allow NetAdmins to access VisaService.
