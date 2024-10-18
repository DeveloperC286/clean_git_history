use clap::{ArgGroup, Parser};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
#[command(group(
            ArgGroup::new("from")
                .required(true)
                .args(["from_commit_hash", "from_reference"]),
        ))]
pub(crate) struct Arguments {
    #[arg(
        long,
        group = "from",
        help = "The Git commit hash from where to start taking the range of commits from till HEAD. The range is inclusive of HEAD and exclusive of the provided Git commit hash."
    )]
    pub(crate) from_commit_hash: Option<String>,

    #[arg(
        long,
        group = "from",
        help = "The Git reference from where to start taking the range of commits from till HEAD. The range is inclusive of HEAD and exclusive of the provided reference."
    )]
    pub(crate) from_reference: Option<String>,

    #[arg(
        long,
        help = "If the flag is enabled then any Git merge commits are ignored, otherwise a merge commit's presence will cause linting to fail."
    )]
    pub(crate) ignore_merge_commits: bool,

    #[arg(
        long,
        help = "The maximum number of commits allowed, if exceeded will cause linting to fail. If set to 0 this check is disabled.",
        default_value = "0"
    )]
    pub(crate) max_commits: usize,
}
