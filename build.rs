//! Stamp a build-identity string into the binary (zipline#64).
//!
//! Emits `ZPR_BUILD_DESCRIBE` for `src/lib.rs` to compose into
//! `BUILD_VERSION` as `<pkg-version> (<describe>)`.
//!
//! Precedence:
//! 1. `ZPR_BUILD_ID` set in the environment — used verbatim, no git run.
//! 2. `git -c safe.directory=<manifest dir> describe --always --dirty --tags`
//!    run with the manifest directory as cwd. The `-c safe.directory` is
//!    load-bearing: the documented container build runs as root over a
//!    checkout owned by another uid, and without it git refuses ("dubious
//!    ownership") and every binary silently stamps `unknown`.
//! 3. The literal `unknown`, with a `cargo:warning=` naming the reason.
//!    The build never fails for want of git metadata.

use std::process::Command;

fn main() {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");

    println!("cargo:rerun-if-env-changed=ZPR_BUILD_ID");

    let describe = match std::env::var("ZPR_BUILD_ID") {
        Ok(id) => id,
        Err(_) => git_describe(&manifest_dir),
    };

    println!("cargo:rustc-env=ZPR_BUILD_DESCRIBE={describe}");
}

/// Run `git describe` in `manifest_dir`, falling back to `unknown` (with a
/// build-log warning quoting git's own stderr) if it cannot answer.
fn git_describe(manifest_dir: &str) -> String {
    // Rebuild when HEAD moves. Ask git for the real path: in a `git worktree`
    // `.git` is a file and the literal `.git/HEAD` does not exist.
    if let Ok(out) = Command::new("git")
        .args(["rev-parse", "--git-path", "HEAD"])
        .current_dir(manifest_dir)
        .output()
        && out.status.success()
    {
        let head = String::from_utf8_lossy(&out.stdout);
        let head = head.trim();
        if !head.is_empty() {
            println!("cargo:rerun-if-changed={head}");
        }
    }

    let describe = Command::new("git")
        .args([
            "-c",
            &format!("safe.directory={manifest_dir}"),
            "describe",
            "--always",
            "--dirty",
            "--tags",
        ])
        .current_dir(manifest_dir)
        .output();

    match describe {
        Ok(out) if out.status.success() => {
            let s = String::from_utf8_lossy(&out.stdout).trim().to_string();
            if s.is_empty() {
                println!("cargo:warning=git describe printed nothing; version suffix is 'unknown'");
                "unknown".to_string()
            } else {
                s
            }
        }
        Ok(out) => {
            let stderr = String::from_utf8_lossy(&out.stderr);
            println!(
                "cargo:warning=git describe failed ({}); version suffix is 'unknown': {}",
                out.status,
                stderr.trim().replace('\n', " ")
            );
            "unknown".to_string()
        }
        Err(e) => {
            println!("cargo:warning=could not run git ({e}); version suffix is 'unknown'");
            "unknown".to_string()
        }
    }
}
