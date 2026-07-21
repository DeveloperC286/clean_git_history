use anyhow::{Context, Result};

use crate::linting_results::CommitError;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Commit {
    pub hash: String,
    pub message: String,
    number_of_parents: usize,
}

impl Commit {
    pub(super) fn from_git(commit: &git2::Commit) -> Result<Commit> {
        let number_of_parents = commit.parents().len();
        let message = commit
            .message()
            .with_context(|| {
                format!(
                    "Can not read the commit message for the commit with the hash '{}'.",
                    commit.id()
                )
            })?
            .to_string();

        trace!(
            "Found the commit message {message:?} for the commit with the hash '{}'.",
            commit.id()
        );

        debug!(
            "The commit with the hash '{}' has {:?} parents.",
            commit.id(),
            number_of_parents,
        );

        Ok(Commit {
            hash: commit.id().to_string(),
            message,
            number_of_parents,
        })
    }

    /// Return a shortened, 7-character representation of the commit hash.
    ///
    /// Truncation is performed on `char` boundaries so it is safe for any
    /// string, though git hashes are always hex and therefore ASCII.
    pub(crate) fn short_hash(&self) -> String {
        self.hash.chars().take(7).collect()
    }

    pub(super) fn is_merge_commit(&self) -> bool {
        let is_merge_commit = self.number_of_parents > 1;

        if is_merge_commit {
            warn!("Commit {:?} is a merge commit.", self.hash);
        }

        is_merge_commit
    }

    /// Lint this commit and return any linting errors found.
    pub(crate) fn lint(&self) -> Vec<CommitError> {
        let mut errors = Vec::new();

        if self.is_merge_commit() {
            errors.push(CommitError::MergeCommit);
        }

        errors
    }
}
