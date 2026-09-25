# Visa-service-interpreted attribute retention fixture (zipline#105).
# Three file stores are declared in the config: `addrstore` vends only
# device.zpr_addr (static-address grants), `hoststore` vends only
# device.hostname{} (the DNS hosts index), and `colorstore` vends only
# user.color. NO policy statement below references any of their returned
# attributes. The visa service reads device.zpr_addr and device.hostname
# directly, so the compiler must retain `addrstore` and `hoststore`
# anyway -- while `colorstore`, vending nothing the visa service
# interprets, must still be pruned.

define Web as a service.

# In policy you can define "administrators" in any way you want.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

allow NetAdmins to access Web.

# VisaService is a reserved name.
allow NetAdmins to access VisaService.
