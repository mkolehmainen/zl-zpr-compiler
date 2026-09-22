# Pruning fixture (zipline#76): the companion .zplc declares a zpr-attr/1
# attribute service, but no policy statement references its attributes and it
# vends no identity attributes, so the weaver must prune it. Named test-* so
# can_compile_misc_test_policies sweeps it — it MUST compile.

define Web as a service.

# References only the built-in default service's attribute; nothing marks the
# `zipline` attribute service used.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

allow NetAdmins to access Web.
