# Deliberately-failing fixture (zipline#109): companion ZPL for
# bad-zpr-addr-oidc-proxy.zplc. Copy of test-oidc-proxy-provider-ts.zpl; the
# failure is the ["zpr.addr", ...] pin in the proxy provider in the .zplc.

define Webby as a service.

# `domain` resolves through the google trusted service (hd -> user.domain).
allow domain:'example.com' users to access Webby.
