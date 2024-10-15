#[macro_use]
extern crate log;
extern crate pretty_env_logger;

use anyhow::{bail, Context, Result};
use clap::Parser;
use git2::Repository;

mod cli;
mod commits;

use crate::cli::Arguments;
use crate::commits::Commits;

const ERROR_EXIT_CODE: i32 = 1;

fn main() {
    pretty_env_logger::init();
    trace!("Version {}.", env!("CARGO_PKG_VERSION"));
    let arguments = cli::Arguments::parse();
    debug!("The command line arguments provided are {:?}.", arguments);

    if let Err(err) = run(arguments) {
        error!("{:?}", err);
        std::process::exit(ERROR_EXIT_CODE);
    }
}

fn run(arguments: Arguments) -> Result<()> {
    let repository = Repository::open_from_env().context("Unable to open the Git repository.")?;
    let commits = match (arguments.from_commit_hash, arguments.from_reference) {
        (Some(from_commit_hash), None) => Commits::from_commit_hash(&repository, from_commit_hash),
        (None, Some(from_reference)) => Commits::from_reference(&repository, from_reference),
        (_, _) => {
            bail!("Invalid combination of from arguments.");
        }
    }
    .context("Unable to parse commits from the Git repository.")?;

    if !arguments.ignore_merge_commits && commits.contains_merge_commits() {
        bail!("Contains merge commits.");
    }

    Ok(())
}
