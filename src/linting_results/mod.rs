use crate::commits::commit::Commit;

mod github_actions;
mod pretty;

/// The representation of an error that an individual commit can have.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum CommitError {
    MergeCommit,
}

/// The representation of an error for the collection of commits as a whole.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CommitsError {
    MaxCommitsExceeded {
        max_commits: usize,
        actual_commits: usize,
    },
}

/// Per-commit linting errors, in the order the commits were walked in.
pub struct CommitErrors {
    pub(crate) errors: Vec<(Commit, Vec<CommitError>)>,
}

impl CommitErrors {
    /// Builds the per-commit linting errors, or `None` if none of the commits have any.
    pub(crate) fn new(errors: Vec<(Commit, Vec<CommitError>)>) -> Option<Self> {
        (!errors.is_empty()).then_some(CommitErrors { errors })
    }
}

/// Aggregate linting errors for the commits collection.
pub struct CommitsErrors {
    pub(crate) errors: Vec<CommitsError>,
}

impl CommitsErrors {
    /// Builds the aggregate linting errors, or `None` if `actual_commits` does not exceed `max_commits`.
    pub(crate) fn new(max_commits: Option<usize>, actual_commits: usize) -> Option<Self> {
        let max_commits = max_commits?;

        if actual_commits <= max_commits {
            return None;
        }

        Some(CommitsErrors {
            errors: vec![CommitsError::MaxCommitsExceeded {
                max_commits,
                actual_commits,
            }],
        })
    }
}

/// A representation of all linting errors found in the range of commits.
pub struct LintingResults {
    pub commit_errors: Option<CommitErrors>,
    pub commits_errors: Option<CommitsErrors>,
}

impl LintingResults {
    pub fn pretty(&self) -> String {
        pretty::print_all(self)
    }

    pub fn github_actions(&self) -> String {
        github_actions::print_all(self)
    }
}
