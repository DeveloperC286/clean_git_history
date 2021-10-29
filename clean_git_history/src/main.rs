#[macro_use]
extern crate log;
extern crate pretty_env_logger;

use std::process::exit;

use git2::Repository;
use structopt::StructOpt;

use clean_git_history_lib::Commits;

mod cli;

const ERROR_EXIT_CODE: i32 = 1;

fn main() {
    pretty_env_logger::init();
    let arguments = cli::Arguments::from_args();
    debug!("The command line arguments provided are {:?}.", arguments);

    match Repository::open_from_env() {
        Ok(repository) => {
            let commits = match (arguments.from_commit_hash, arguments.from_reference) {
                (Some(from_commit_hash), None) => {
                    Commits::from_commit_hash(&repository, &from_commit_hash)
                }
                (None, Some(from_reference)) => {
                    Commits::from_reference(&repository, &from_reference)
                }
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
                    exit(ERROR_EXIT_CODE);
                }
            }
        }
        Err(_) => {
            error!("Failed to open a Git repository from the current directory or Git environment variables.");
            exit(ERROR_EXIT_CODE);
        }
    }
}
