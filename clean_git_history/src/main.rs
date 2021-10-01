#[macro_use]
extern crate log;
extern crate pretty_env_logger;

use std::process::exit;
use structopt::StructOpt;

use crate::model::commits::Commits;

mod cli;
mod model;

const ERROR_EXIT_CODE: i32 = 1;

fn main() {
    pretty_env_logger::init();
    let arguments = cli::Arguments::from_args();
    debug!("The command line arguments provided are {:?}.", arguments);

    let commits = match (arguments.from_commit_hash, arguments.from_reference) {
        (Some(from_commit_hash), None) => Commits::from_commit_hash(from_commit_hash),
        (None, Some(from_reference)) => Commits::from_reference(from_reference),
        (_, _) => {
            unreachable!(
                "Invalid combination of from arguments, should have been caught by structopt."
            );
        }
    };

    match commits {
        Ok(commits) => {
            if !arguments.ignore_merge_commits && commits.contains_merge_commits() {
                exit(ERROR_EXIT_CODE);
            }
        }
        Err(_) => {
            // Different error code to the assertion failure?
            exit(ERROR_EXIT_CODE);
        }
    }
}
