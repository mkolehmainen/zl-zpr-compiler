//! The ZPL compiler produces ZPR policy from a ZPL source file and associated
//! configuration.
//!
//! The crate produces a binary named `zpc` which is the command line interface to
//! the compiler.
//!
//! A library is also available for direct access.  See [compilation::CompilationBuilder].

// This lib.rs is here to allow the integration tests
// to use the modules in the src directory.

/// Build-identity string: `<pkg-version> (<git describe>)`, stamped by
/// `build.rs` at build time (zipline#64). The suffix is
/// `git describe --always --dirty --tags`, or the value of `ZPR_BUILD_ID`
/// verbatim, or the literal `unknown` when neither is available.
pub const BUILD_VERSION: &str = concat!(
    env!("CARGO_PKG_VERSION"),
    " (",
    env!("ZPR_BUILD_DESCRIBE"),
    ")"
);

mod allow;
pub mod compilation;
pub mod compiler;
mod config;
mod config_api;
mod context;
pub mod crypto;
mod define;
pub mod dump;
pub mod dumpv2;
pub mod errors;
mod fabric;
mod fabric_util;
mod lex;
mod never;
mod parser;
pub mod policybinaryv2;
pub mod policybuilder;
pub mod policywriter;
pub mod protocols;
mod ptypes;
mod putil;
mod weaver;
pub mod zpl;
mod zplstr;
