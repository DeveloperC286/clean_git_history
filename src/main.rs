#[macro_use]
extern crate log;
extern crate pretty_env_logger;

use anyhow::{bail, Context, Result};
use clap::Parser;
use git2::Repository;

mod commits;

use crate::commits::Commits;

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
        help = "The Git reference from where to start taking the range of commits from till HEAD to lint. The range is inclusive of HEAD and exclusive of the provided reference."
    )]
    pub(crate) from: String,
}

fn main() {
    pretty_env_logger::init();
    trace!("Version {}.", env!("CARGO_PKG_VERSION"));
    let arguments = Arguments::parse();
    debug!("The command line arguments provided are {:?}.", arguments);

    if let Err(err) = run(arguments) {
        error!("{:?}", err);
        std::process::exit(ERROR_EXIT_CODE);
    }
}

fn run(arguments: Arguments) -> Result<()> {
    let repository = Repository::open_from_env().context("Unable to open the Git repository.")?;
    let commits = Commits::from_git(&repository, arguments.from)?;

    if commits.contains_merge_commits() {
        bail!("Contains merge commits.");
    }

    if let Some(max_commits) = arguments.max_commits {
        if commits.len() > max_commits {
            bail!(format!(
                "Exceeded the maxium number of commits {:?} with {:?} commits.",
                arguments.max_commits,
                commits.len()
            ));
        }
    }

    Ok(())
}
