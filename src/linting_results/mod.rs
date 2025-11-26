use std::collections::{HashMap, VecDeque};

use crate::commits::commit::Commit;

mod pretty;

/// The representation of an error that an individual commit can have.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum CommitError {
    /// Commit is a merge commit (has multiple parents).
    MergeCommit,
}

/// The representation of an error for the collection of commits as a whole.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CommitsError {
    /// The number of commits exceeds the maximum allowed.
    MaxCommitsExceeded {
        max_commits: usize,
        actual_commits: usize,
    },
}

/// Per-commit linting errors.
pub struct CommitErrors {
    pub(crate) order: VecDeque<Commit>,
    pub(crate) errors: HashMap<Commit, Vec<CommitError>>,
}

impl CommitErrors {
    pub(crate) fn new(order: VecDeque<Commit>, errors: HashMap<Commit, Vec<CommitError>>) -> Self {
        CommitErrors { order, errors }
    }
}

/// Aggregate linting errors for the commits collection.
pub struct CommitsErrors {
    pub(crate) errors: Vec<CommitsError>,
}

impl CommitsErrors {
    pub(crate) fn new(errors: Vec<CommitsError>) -> Self {
        CommitsErrors { errors }
    }
}

/// A representation of all linting errors found in the range of commits.
pub struct LintingResults {
    pub commit_errors: Option<CommitErrors>,
    pub commits_errors: Option<CommitsErrors>,
}

impl LintingResults {
    /// Get a pretty representation of the linting results as a string, suitable as output for a user.
    pub fn pretty(&self) -> String {
        pretty::print_all(self)
    }
}
