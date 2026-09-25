# Visa-service-interpreted retention, referenced-store variant (zipline#105).
# `dualstore` is BOTH referenced by ZPL (hair_color below resolves through
# it) and a vendor of a visa-service-interpreted attribute
# (device.zpr_addr). It must be woven exactly once -- the ordinary
# attribute-reference path marks it used before the retain pass runs, so
# the retain pass must skip it (and emit no retention diagnostic for it).

define Web as a service.

# `hair_color` resolves through dualstore (hair_color -> user.hair_color).
allow hair_color:red users to access Web.

# In policy you can define "administrators" in any way you want.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

# VisaService is a reserved name.
allow NetAdmins to access VisaService.
