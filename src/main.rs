#[macro_use]
extern crate log;
extern crate pretty_env_logger;

use structopt::StructOpt;

mod cli;

fn main() {
    pretty_env_logger::init();
    let arguments = cli::Arguments::from_args();
    debug!("The command line arguments provided are {:?}.", arguments);
}
