use structopt::{clap::ArgGroup, StructOpt};

#[derive(Debug, StructOpt)]
#[structopt(
    name = "clean_history",
    about = "A Git history linter to make sure it stays clean.",
    group = ArgGroup::with_name("from").required(true)
)]
pub struct Arguments {
    #[structopt(
        long,
        group = "from",
        help = "The Git commit hash from where to start taking the range of commits from till HEAD. The range is inclusive of HEAD and exclusive of the provided Git commit hash."
    )]
    pub from_commit_hash: Option<String>,

    #[structopt(
        long,
        group = "from",
        help = "The Git reference from where to start taking the range of commits from till HEAD. The range is inclusive of HEAD and exclusive of the provided reference."
    )]
    pub from_reference: Option<String>,
}
