//! zipline#64: the build-identity const stamped at build time.

use std::process::Command;

/// True when `git describe` can answer for this checkout at test time — the
/// precondition for the stamped suffix being a real describe string rather
/// than the documented `(unknown)` fallback (git-less source archives,
/// vendored trees, builders without a `git` executable).
fn git_metadata_available() -> bool {
    Command::new("git")
        .args(["describe", "--always", "--dirty", "--tags"])
        .current_dir(env!("CARGO_MANIFEST_DIR"))
        .output()
        .map(|out| out.status.success())
        .unwrap_or(false)
}

/// `BUILD_VERSION` is `<pkg-version> (<suffix>)`. The structural assertions
/// hold everywhere; the suffix is asserted to be a real describe string only
/// when git metadata is available, because `(unknown)` is the documented and
/// supported fallback for git-less builds — a test rejecting it would make
/// `cargo test` fail in exactly the environments the fallback exists for.
#[test]
fn build_version_is_stamped() {
    let v = zplc::BUILD_VERSION;
    assert!(!v.is_empty(), "BUILD_VERSION is empty");
    assert!(
        v.starts_with(concat!(env!("CARGO_PKG_VERSION"), " (")) && v.ends_with(')'),
        "BUILD_VERSION is not '<pkg-version> (<suffix>)': {v}"
    );
    assert!(
        v.len() > concat!(env!("CARGO_PKG_VERSION"), " ()").len(),
        "BUILD_VERSION has an empty suffix: {v}"
    );
    if git_metadata_available() {
        assert!(
            !v.ends_with("(unknown)"),
            "git describe works here, yet the suffix is the fallback: {v}"
        );
    }
}
