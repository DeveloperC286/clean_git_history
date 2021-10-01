use structopt::{clap::ArgGroup, StructOpt};

#[derive(Debug, StructOpt)]
#[structopt(
    name = "clean_git_history",
    about = "A Git history linter to make sure it stays clean.",
    group = ArgGroup::with_name("from").required(true)
)]
pub(crate) struct Arguments {
    #[structopt(
        long,
        group = "from",
        help = "The Git commit hash from where to start taking the range of commits from till HEAD. The range is inclusive of HEAD and exclusive of the provided Git commit hash."
    )]
    pub(crate) from_commit_hash: Option<String>,

    #[structopt(
        long,
        group = "from",
        help = "The Git reference from where to start taking the range of commits from till HEAD. The range is inclusive of HEAD and exclusive of the provided reference."
    )]
    pub(crate) from_reference: Option<String>,

    #[structopt(
        long,
        help = "If the flag is enabled then any Git merge commits are ignored, otherwise a merge commit's presence will cause linting to fail."
    )]
    pub(crate) ignore_merge_commits: bool,
}
