allow clearance:classified government users to access classified
services.


# test
define database as a service with user.uid:1234.
define employee as a user with user.uid.

allow lazy, color:red employees to access classified databases on tint:sales devices.

allow device.zpr.adapter.cn:  users to access classified services.


# FIXME?
# allow classified services to access database.

# In policy you can define "administrators" in any way you want.
define NetAdmins as users with device.zpr.adapter.cn:'admin.zpr.org'.

# VisaService is a reserved name.
allow hair_color:red NetAdmins to access VisaService.
