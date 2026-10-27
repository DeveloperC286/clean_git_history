use clap::ValueEnum;

#[derive(Clone, Debug, PartialEq, ValueEnum)]
pub enum Output {
    /// Print nothing, only set the exit code.
    Quiet,
    /// Auto-detect GitHub Actions via the GITHUB_ACTIONS environment variable,
    /// using the GitHub Actions format when detected and the pretty format otherwise.
    Default,
    /// Force a human readable, colourised output format.
    Pretty,
    /// Force the GitHub Actions workflow command output format.
    #[value(name = "github")]
    GitHub,
}

/// The concrete output format to use, after any auto-detection has been applied.
#[derive(Debug, PartialEq)]
pub enum ResolvedOutput {
    Quiet,
    Pretty,
    GitHub,
}

impl Output {
    /// Resolves the requested output format into a concrete one, detecting GitHub Actions for the
    /// default format.
    pub fn resolve(&self) -> ResolvedOutput {
        match self {
            Output::Quiet => ResolvedOutput::Quiet,
            Output::Pretty => ResolvedOutput::Pretty,
            Output::GitHub => ResolvedOutput::GitHub,
            Output::Default => {
                if std::env::var("GITHUB_ACTIONS").is_ok() {
                    ResolvedOutput::GitHub
                } else {
                    ResolvedOutput::Pretty
                }
            }
        }
    }
}
