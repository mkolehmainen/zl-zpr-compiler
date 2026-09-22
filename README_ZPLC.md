# ZPLC - ZPL Configuration

ZPLC uses TOML syntax.  Work in progress.



## Layout

Suggest layout within the TOML file:

* nodes
* trusted_services
* bootstrap
* protocols
* services


## Nodes

Only one node is supported currently in a ZPRnet.  Syntax:

```toml
[nodes.<NODEID>]
provider = [["<KEY>", "<VALUE>"]]
zpr_address = "fd5a..."
```
* `provider` - The set of attributes required in order to provide the node "service". These
attributes cannot come from an external service they must be "built in".  Typically the
only attribute you can use here is `device.zpr.adapter.cn` which is the `CN` value from
the nodes Noise certificate.
* `zpr_address` - IPv6 ZPRnet address for the node. Node must be preconfigured with this
same address.

### Topology

If there are multiple nodes you need to define their substrate addresses. We support multiple
substrate addresses per node. Each address is specified in `HOST:PORT` format and is tied
to an identifier.  In the example below the identifier is `i0`.


```toml
[nodes.<NODEID>]
provider = [[]]
#...

[nodes.<NODEID>.substrate_addrs]
i0 = "10.0.0.1:5000"
```

To connect nodes you must specific `links` in the zplc file.

```toml
[links.<LINKID>]
attributes = [["zpr.cost", "1"]] # this is the default
peers = [ { node = "<NODEID>" },
          { node = "<NODEID>" } ]
```

If a node has multiple substrate addresses then reference the substrate address name
in the peers list, eg:

```toml
[links.<LINKID>]
attributes = [["zpr.cost", "1"]] # this is the default
peers = [ { node = "<NODEID>" },
          { node = "<NODEID>", interface = "i3" } ]
```

### Link attributes

Link attributes are what a ZPL `over` clause matches against, eg
`allow red users to access database over secure, location:usa links.`

An entry is either a key/value pair or a **tag**. A tag is written with a `#`
prefix and an empty value, the same spelling used by `returns_attributes`:

```toml
[links.<LINKID>]
attributes = [["zpr.cost", "1"],      # key/value
              ["location", "usa"],    # key/value
              ["#secure", ""]]        # tag
```

Giving a `#`-prefixed key a non-empty value is an error.

Because ZPL and ZPLC are always compiled together, the compiler can check an `over`
clause against the topology. Attribute names and values are treated differently:

- An `over` clause naming a link attribute that **no configured link carries** is an
  **error**. Such a statement could never match anything.
- An `over` clause naming a **value** that no configured link carries — while the
  attribute itself does exist — is a **warning** (`location:use` where the configured
  values are `usa` and `eu`). This catches typos without failing the build, since link
  values are topology data a later configuration edit may legitimately introduce, and
  value matching is ultimately the visa service's job at enforcement time. Compile with
  `--werror` to make it fatal.

Tags carry no value, so only the attribute check applies to them.


## Trusted Services

The trusted services block contains details about the API to use to talk to it, as
well as things like attributes returned.

Syntax:

```toml
  [trusted_service.<TSNAME>]
  api = "validation/2"
  service = ""
  client = ""
  cert_path = ""
  returns_attributes = []
  identity_attributes = []
  provider = []
```

The **TSNAME** of `default` is special and is used to check the adapter CN values.
It is responsible for the property: `device.zpr.adapter.cn`.  The default
service requires a `cert_path` which should be set to the certificate of the
authority which has signed the NOISE certs given to the adapters.

```toml
[trusted_services.default]
cert_path = "path/to/ca/cert.pem"
```


If you omit `trusted_services.default` then certificates will not be checked.

For non default trusted services, the field meanings are:

* `api` - Configures how the visa service uses the trusted service. Valid values are:
  * `validation/2` - An validation service.  Meaning that the service can provide
     validation of authentication to a visa service, and actor authentication services
     to an adapter.
  * `file` - A file-backed attribute source offered by the visa service itself, with no
     network presence. The visa service loads the attributes from a local `<TSNAME>.json`
     file at runtime. See *File Trusted Services* below.
  * `oidc` - An OpenID Connect identity provider (e.g. Google). The adapter talks to the
     provider directly; the visa service only needs the provider's JWKS to verify tokens.
     See *OIDC Trusted Services* below.
  * `zpr-attr/1` - A networked attribute service the visa service queries over HTTPS.
     See *Attribute Services (zpr-attr/1)* below.
  * *addition values TBD*
* `service` - Sets the service ID used in the **services** block for the visa-service
  facing service provided by this trusted service.  This is *optional* and by default
  the compiler expects to find a service block named `<TSNAME>-vs`.
* `client` - Sets the service ID used in the **services** block for the actor/adapter
  facing service provided by this trusted service.  This is *optional* and by default
  the compiler expects to find a service block named `<TSNAME>-client`.
* `cert_path` - Used to pass a TLS certificate to the visa service which is used to
  verify the service connection.
* `returns_attributes` - List of attribute keys returned by the service mapped to
  ZPL attribute names.
* `identity_attributes` - Subset of the `returns_attributes` that denote identity.
* `provider` - Attribute key/value tuples of the actor (or actors) that provide this service.
* `expiration_seconds` - Optional lifetime (in seconds) of the attributes this service vouches
  for. Accepted on `validation/2`, `file`, `oidc`, and `zpr-attr/1` services (required and
  positive for `oidc` and `zpr-attr/1`); rejected on `default`. Must be a
  non-negative integer that fits in a 32-bit unsigned value. Omitted or `0` means the visa
  service selects the lifetime at runtime (from the service or its own default).

Every trusted-service ID (the `<TSNAME>`) must match `[A-Za-z0-9_-]+`. For a `file` service this
ID is also the filename stem — the visa service loads attributes from `<TSNAME>.json`.


A trusted service for validation is really two services: the service that the visa service
talks to to confirm authentication and retrieve attributes, and the service that an actor
talks to to perform authentication.  These services use varying protocols and ports like
any service on the ZPRnet.  To configure these services, the compiler requires that there
are `services` blocks defined in the usual way.  The IDs attached to these blocks are either
defaults or are set using the `service` and `client` properties of the trusted service
(see above).

Communication with the trusted service uses a set of pre-defined protocols which must be
supported by the ZPR implementation.  The protocols defined in the ZPR Referernce
Implementation are:

* `zpr-oauthrsa` - An actor OAuth-derived HTTPS protocol used by an adapter to authenicate its
  actor using an RSA key.
* `zpr-validation2`- A visa service HTTPS OAuth protocol which allows the visa service to
  request an authentication token based on an identifier.

Example:

```toml
[services.foo-vs]
protocol = "zpr-validation2"
port = 4444

[services.foo-client]
protocol = "zpr-oauthrsa"
port = 1234
```

### File Trusted Services

A `file` trusted service supplies actor attributes from a local JSON file loaded by the visa
service rather than over the network. Declare only `returns_attributes` (at least one mapping)
and, optionally, `expiration_seconds`:

```toml
[trusted_services.attrfile]
api = "file"
returns_attributes = ["hair_color -> user.hair_color", "lazy -> #user.lazy"]
expiration_seconds = 3600
```

Because a file service has no network presence, the `service`, `client`, `cert_path`, `provider`,
and `identity_attributes` properties are **not** allowed. The compiler weaves it as a service
offered by the visa service CN (`vs.zpr`) with no endpoints and no communication policy. The
attribute mappings use the same `->` syntax (and single / `{}` multi / `#` tag forms) as any other
trusted service (see *Attributes* below).

### OIDC Trusted Services

An `oidc` trusted service declares an OpenID Connect identity provider (such as Google)
as an attribute source. The adapter performs the OIDC flow with the provider directly;
the visa service only verifies the resulting ID tokens against the provider's JWKS.

```toml
[trusted_services.google]
api = "oidc"
issuer = "https://accounts.google.com"
jwks_uri = "https://www.googleapis.com/oauth2/v3/certs"
client_id = "my-client-id.apps.googleusercontent.com"
allowed_domains = ["example.com"]
expiration_seconds = 3600
service = "google-jwks"
returns_attributes = ["sub -> user.sub", "email -> user.email"]
identity_attributes = ["sub"]
```

Properties:

* `issuer` - **Required.** The provider's issuer URL as it appears in its tokens. Must be
  an `https://` URL with no query string or fragment.
* `jwks_uri` - **Required.** The provider's JWKS endpoint, from which the visa service
  fetches the token-signing keys. Must be `https://`.
* `client_id` - **Required.** The OAuth client ID registered with the provider; must be
  non-empty.
* `client_secret` - Optional OAuth client secret, for providers that require one.
* `scopes` - Optional list of OAuth scopes to request. Defaults to
  `["openid", "email", "profile"]`. If set, it must include `"openid"`.
* `allowed_domains` - **Required**, non-empty. Account domains accepted from this
  provider. Use `["*"]` to accept any account.
* `seed_jwks` - Optional path to a local JWKS file used to seed key material at compile
  time (resolved relative to the `.zplc` file).
* `expiration_seconds` - **Required** for `oidc`, and must be positive: the lifetime of
  the attributes this provider vouches for.
* `max_auth_age_seconds` - Optional maximum age (in seconds) of the user's
  authentication before re-authentication is required — the session ceiling. Must be a
  non-negative integer that fits in a 32-bit unsigned value. Defaults to `0` (no limit),
  but any **nonzero** value must be at least `expiration_seconds`: a ceiling below the
  credential lifetime would let a credential outlive the session that authorized it, and
  the compiler rejects it with `max_auth_age_seconds must be >= expiration_seconds`.
* `allow_offline_access` - Optional boolean, default `false`. Whether to request
  offline access (refresh tokens) from the provider. Setting it to `true` **requires a
  nonzero `max_auth_age_seconds`**: a refresh token with no session ceiling could renew
  forever, so the compiler rejects the combination with `allow_offline_access requires
  max_auth_age_seconds (the session ceiling)`.
* `returns_attributes` - **Required**, at least one mapping, using the same `->` syntax
  as any other trusted service. The `zpr.` sub-namespace remains reserved.
* `identity_attributes` - **Required** and must be exactly `["sub"]` — the OIDC subject
  is the only stable identity. In particular, `"email"` is rejected as an identity
  attribute because addresses are mutable and reusable.
* `service` - Optional, as for other trusted services. If omitted, the compiler warns:
  without a declared service the visa service will need direct internet egress to reach
  the `jwks_uri`.

Because the adapter talks to the provider directly and TLS to the provider is verified
against system roots, the `client`, `provider`, `cert_path`, and `prefix` properties are
**not** allowed on an `oidc` trusted service. The `default` trusted service cannot use
`api = "oidc"`.

### Attribute Services (zpr-attr/1)

A `zpr-attr/1` trusted service declares a networked attribute service: an HTTPS API the
visa service queries for actor attributes, keyed on identities vended by other trusted
services (the same decorating-store role as `api = "file"`, but over the network). The
wire protocol is specified in `zl-zpr-dev-context/docs/ATTRIBUTE_SERVICE.md`.

```toml
[trusted_services.zipline]
api = "zpr-attr/1"
url = "https://attrs.zipline.example/tenant-7"    # base of the API; https required
ca_cert_path = "zipline-ca.pem"                   # optional: PEM, embedded in the policy
timeout_seconds = 5                               # optional: 1..=30, default 5
expiration_seconds = 3600                         # required: how long returned attributes live
returns_attributes = [
  "dept -> user.dept",             # single-valued
  "roles -> user.role{}",          # multi-valued
  "contractor -> #user.contractor" # tag
]
```

Properties:

* `url` - **Required.** The base URL of the service's API. Must be `https://` with a
  host and no query string or fragment. It may carry a path prefix; the visa service
  appends `/query` and `/schema`. A trailing slash is normalised away.
* `ca_cert_path` - Optional path, relative to the `.zplc` file, of a PEM file holding
  one or more `CERTIFICATE` blocks. Its **contents** are embedded in the compiled
  policy, so the pin is signed along with everything else. When present it is
  **exclusive**: the visa service trusts only these roots for this service and disables
  the built-in system roots. Absent means system roots.
* `timeout_seconds` - Optional whole-request timeout the visa service applies to every
  call. An integer from 1 to 30; defaults to 5.
* `expiration_seconds` - **Required** and must be positive: the default lifetime of
  every attribute returned, and the ceiling on any lifetime the service asks for. The
  visa service enforces a 60-second floor at runtime.
* `returns_attributes` - **Required**, at least one mapping, using the same `->` syntax
  as any other trusted service. The `zpr.` sub-namespace remains reserved.

An attribute service is a decorating store keyed on other services' identities, so
`identity_attributes` is **not** allowed (the same rule as `api = "file"`). The
BAS-era `provider`, `client`, `cert_path`, and `prefix` properties are not allowed
either. **`service` is reserved**: it will one day name a ZPR service through which the
visa service reaches an on-net attribute service; in `zpr-attr/1` it is rejected, and
reaching the service over ordinary IP is the only mode. The `default` trusted service
cannot use `api = "zpr-attr/1"`.

Like a `file` service, an attribute service is woven with no endpoints and no
communication policy, is retained when a policy statement references one of its
attributes, and is pruned otherwise.

### Attributes

An attribute is of the form: `<NAMESPACE>.<ATTR_KEY>`.  There may be additional periods
in the `<ATTR_KEY>` value.

Every attribute must be in one of the ZPR namespaces: "device", "user", or "service".

Valid attribute examples:
* `user.id`
* `device.tmp.key_hash`
* `service.type`

Attributes from services may be single value, multi value, or tags.  An attribute list
(eg, `returns_attributes` or `identity_attributes`) is a list of strings.  The type of
the attribute is set as:

* **Single Value** - Just a plain string, eg `"user.clearance"`.
* **Multi Value** - Add a '{}' to the end, eg `"user.role{}"`.
* **Tag** - Prefixed with a hash mark (`#`), eg `"#device.secure`.

When specifying the `returns_attributes` use a map format with an arrow '->':


```toml
returns_attributes = [
  "tint -> device.tint",
  "color -> user.color",
  "govt -> #user.government",
  "bas_id -> user.id",
  "roles -> user.role{}"
]
```

And then for `identity_attributes` make sure to use the service name (not the
ZPL name).  For example, given the above returns attributes:

```toml
identity_attributes = [ "bas_id" ]
```


## Bootstrap

The boostrap section maps a `CN` value (from noise keys) to a cooresponding public
RSA key file.  When adapters connect with these `CN` values, they can perform "self authentication"
which ends up having the visa service check that the adapter is using the correct private
key.

Bootstrap is required for services that need to connect before there are trusted services
connected.

Syntax:

```toml
[boostrap]
"some.cn.value.here" = "path-to-rsa-pub-key.pem"
```


## Protocols

Use protocols blocks to define protocols that are needed to access your services.

Syntax:
```toml
[protocols.<NAME>]
l4protocol = "TCP"
port = 80

# or if using ICMP
[protocols.ping]
l4protocol = "ICMP4"
icmp_type = "request-response"
icmp_codes = [0, 8]
```

* `protocols.<NAME>` - The NAME here is used later in `services` blocks to reference
the protocol.
* `l4protocol` - Layer 4 protocol name. One of 'TCP', 'UDP', 'ICMPV6', or 'ICMP' (or 'ICMP4').
* `port` - Port number. Currently only supports a single port number.
* `icmp_type` - Required for the ICMP familty of protocols, possible values are: `request-response` or `oneshot`.
* `icmp_codes` - Is a list of integers.  For `request-response` this is a tuple of
(request-code, response-code).  For `oneshot` this is one or more allowed ICMP codes.



## Services

A service must be defined in the configuration for every service that is
declared in the policy file.  The basic format is:

```toml
[service.<NAME>]
protocol = "" # required
```

The `<NAME>` must match a name in the ZPL policy file.  The `protocol` must match a
protocol block defined elsewhere in the configuration.

Since it is typical to have a protocol like `HTTPS` but then have instances that
use many different ports, it is possible to override some aspects of a protocol in
the service definition, for example:

```toml
[protocol.webtls]
l4protocl = "TCP"
port = 443

[service.WebService]
protocol = "webtls"
port = 3030
```

To associate a service with an actor you need provider attributes. These can
come from the ZPL, but you can also put them in the configuration.  Eg,

```toml
[service.WebService]
protocol = "http"
port = 80
provider = [[ "device.zpr.adapter.cn", "foo.blah"]]
```

If you need a static address for a service, the service adapter needs to specify
a `zpr_addr` in its config file AND the service configuration needs to match
with a `zpr.addr` attribute.  For example,

```toml
[service.WebService]
protocol = "http"
port = 80
provider = [[ "device.zpr.adapter.cn", "foo.blah"], ["zpr.addr", "fd5a:5052:2020::19"]]
```




