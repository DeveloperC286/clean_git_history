#[macro_use]
extern crate log;
extern crate pretty_env_logger;

use structopt::StructOpt;

use crate::model::commits::Commits;

mod cli;
mod model;

const ERROR_EXIT_CODE: i32 = 1;

fn main() {
    pretty_env_logger::init();
    let arguments = cli::Arguments::from_args();
    debug!("The command line arguments provided are {:?}.", arguments);

    let _commits = Commits::from_git(arguments.from_commit_hash, arguments.from_reference);
}
