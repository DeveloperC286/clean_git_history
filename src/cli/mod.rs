use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub(crate) struct Arguments {
    #[arg(
        long,
        help = "The maximum number of commits allowed, if exceeded will cause linting to fail. If set to 0 this check is disabled.",
        default_value = "0"
    )]
    pub(crate) max_commits: usize,

    #[arg(
        help = "The Git reference from where to start taking the range of commits from till HEAD to lint. The range is inclusive of HEAD and exclusive of the provided reference."
    )]
    pub(crate) from: String,
}
