# zipline#6 review: companion ZPL for test-oidc-proxy-provider-ts.zplc.
# Deliberately references neither the proxy service nor device.color, so the
# `attrfile` trusted service is reachable only through the proxy's provider
# attributes.

define Webby as a service.

# `domain` resolves through the google trusted service (hd -> user.domain).
allow domain:'example.com' users to access Webby.
