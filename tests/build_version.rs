//! zipline#64: the build-identity const stamped at build time.

/// `BUILD_VERSION` is `<pkg-version> (<git describe>)`. This test runs inside
/// the real git checkout, so it can only assert the normal (describe) case;
/// the no-git-metadata outcomes are proven by scripted out-of-tree builds
/// (see the PR description).
#[test]
fn build_version_is_stamped() {
    let v = zplc::BUILD_VERSION;
    assert!(!v.is_empty(), "BUILD_VERSION is empty");
    assert!(
        v.contains(env!("CARGO_PKG_VERSION")),
        "BUILD_VERSION does not contain the package version: {v}"
    );
    assert!(
        !v.ends_with("(unknown)"),
        "built inside a git checkout, yet the suffix is the fallback: {v}"
    );
}
