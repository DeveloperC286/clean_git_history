#[macro_use]
extern crate log;
extern crate pretty_env_logger;

use anyhow::{Context, Result};
use clap::Parser;
use git2::Repository;

mod commits;
mod linting_results;
mod output;

use crate::commits::Commits;
use crate::output::Output;

const ERROR_EXIT_CODE: i32 = 1;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub(crate) struct Arguments {
    #[arg(
        long,
        help = "The maximum number of commits allowed, if exceeded will cause linting to fail."
    )]
    pub(crate) max_commits: Option<usize>,

    #[arg(
        long,
        help = "Enable verbose output, respects RUST_LOG environment variable if set."
    )]
    pub(crate) verbose: bool,

    #[arg(
        long,
        default_value = "default",
        help = "Specifies the format for outputting results, acceptable values are quiet, default, and pretty."
    )]
    pub(crate) output: Output,

    #[arg(
        help = "The Git reference from where to start taking the range of commits from till HEAD to lint. The range is inclusive of HEAD and exclusive of the provided reference.",
        default_value = "origin/HEAD"
    )]
    pub(crate) from: String,
}

fn main() {
    let arguments = Arguments::parse();

    // Set up logging: if verbose is true and RUST_LOG is not set, default to info level
    if arguments.verbose && std::env::var("RUST_LOG").is_err() {
        std::env::set_var("RUST_LOG", "info");
    }

    pretty_env_logger::init();

    info!("Version {}.", env!("CARGO_PKG_VERSION"));
    debug!("The command line arguments provided are {arguments:?}.");

    match run(arguments) {
        Ok(exit_code) => std::process::exit(exit_code),
        Err(err) => {
            error!("{err:?}");
            std::process::exit(ERROR_EXIT_CODE);
        }
    }
}

fn run(arguments: Arguments) -> Result<i32> {
    let repository = Repository::open_from_env().context("Unable to open the Git repository.")?;
    let commits = Commits::from_git(&repository, arguments.from)?;

    if let Some(linting_results) = commits.lint(arguments.max_commits) {
        match arguments.output {
            Output::Quiet => {}
            Output::Default => {
                println!("{}", linting_results.pretty());
            }
            Output::Pretty => {
                println!("{}", linting_results.pretty());
            }
        }

        // As we don't want an error printed but linting failed so want to exit unsuccessfully.
        return Ok(1);
    }

    info!("Successfully linted all commits.");
    Ok(0)
}
