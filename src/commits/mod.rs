use std::collections::{HashMap, VecDeque};

use anyhow::{bail, Context, Result};
use git2::{Oid, Repository, Revwalk};

use crate::linting_results::{
    CommitError, CommitErrors, CommitsError, CommitsErrors, LintingResults,
};

pub mod commit;
pub use commit::Commit;

/// A representation of a range of commits within a Git repository, which can have various lints performed upon it after construction.
pub struct Commits {
    commits: VecDeque<Commit>,
}

impl Commits {
    pub fn from_git<T: AsRef<str>>(repository: &Repository, git: T) -> Result<Commits> {
        let oid = parse_to_oid(repository, git.as_ref()).or_else(|error| {
            get_reference_oid(repository, git.as_ref()).map_err(|e| error.context(e))
        })?;
        get_commits_till_head_from_oid(repository, oid)
    }

    /// Lint all commits and return the linting results if any issues are found.
    pub fn lint(&self, max_commits: Option<usize>) -> Option<LintingResults> {
        let mut commit_errors: HashMap<Commit, Vec<CommitError>> = HashMap::new();

        // Check each commit for linting errors
        for commit in self.commits.iter().cloned() {
            let errors = commit.lint();

            if !errors.is_empty() {
                warn!(
                    "Found {} linting errors for the commit {:?}.",
                    errors.len(),
                    commit.hash
                );
                commit_errors.insert(commit, errors);
            }
        }

        // Check for aggregate errors
        let commits_errors = max_commits.and_then(|max| {
            if self.commits.len() > max {
                Some(vec![CommitsError::MaxCommitsExceeded {
                    max_commits: max,
                    actual_commits: self.commits.len(),
                }])
            } else {
                None
            }
        });

        // Return None if no issues found, otherwise build LintingResults
        match (&commit_errors.is_empty(), &commits_errors) {
            (true, None) => None,
            (true, Some(ce)) => Some(LintingResults {
                commit_errors: None,
                commits_errors: Some(CommitsErrors::new(ce.clone())),
            }),
            (false, None) => Some(LintingResults {
                commit_errors: Some(CommitErrors::new(self.commits.clone(), commit_errors)),
                commits_errors: None,
            }),
            (false, Some(ce)) => Some(LintingResults {
                commit_errors: Some(CommitErrors::new(self.commits.clone(), commit_errors)),
                commits_errors: Some(CommitsErrors::new(ce.clone())),
            }),
        }
    }
}

fn get_commits_till_head_from_oid(
    repository: &Repository,
    from_commit_hash: Oid,
) -> Result<Commits> {
    fn get_revwalker(repository: &Repository, from_commit_hash: Oid) -> Result<Revwalk<'_>> {
        let mut commits = repository.revwalk()?;
        commits.simplify_first_parent()?;
        commits.push_head()?;

        commits.hide(from_commit_hash).context(format!(
            "Can not find a commit with the hash '{from_commit_hash}'."
        ))?;
        Ok(commits)
    }

    let revwalker = get_revwalker(repository, from_commit_hash)?;
    let mut commits = VecDeque::new();

    for oid in revwalker {
        let oid = oid?;
        let commit = repository.find_commit(oid)?;
        let commit = Commit::from_git(&commit);
        commits.push_front(commit);
    }

    if commits.is_empty() {
        bail!("No Git commits within the provided range.");
    }

    info!("Found {} commits within the provided range.", commits.len());
    Ok(Commits { commits })
}

fn get_reference_oid(repository: &Repository, matching: &str) -> Result<Oid> {
    let reference = repository
        .resolve_reference_from_short_name(matching)
        .context(format!(
            "Could not find a reference with the name {matching:?}."
        ))?;
    debug!(
        "Matched {matching:?} to the reference {:?}.",
        reference.name().unwrap()
    );
    let commit = reference.peel_to_commit()?;
    Ok(commit.id())
}

fn parse_to_oid(repository: &Repository, oid: &str) -> Result<Oid> {
    match oid.len() {
        1..=39 => {
            debug!("Attempting to find a match for the short commit hash {oid:?}.");
            let matching_oid_lowercase = oid.to_lowercase();

            let mut revwalker = repository.revwalk()?;
            revwalker.push_head()?;

            let matched_commit_hashes: Vec<Oid> = revwalker
                .filter_map(|result| match result {
                    Ok(oid) => {
                        let oid_lowercase = oid.to_string().to_lowercase();

                        if oid_lowercase.starts_with(&matching_oid_lowercase) {
                            debug!("Found a match for the short commit hash {oid:?}.");
                            return Some(oid);
                        }

                        None
                    }
                    Err(_) => None,
                })
                .collect();

            match matched_commit_hashes.len() {
                0 => {
                    bail!(
                        "No actual commit hashes start with the provided short commit hash {matching_oid_lowercase:?}."
                    );
                }
                1 => Ok(*matched_commit_hashes.first().unwrap()),
                _ => {
                    bail!("Ambiguous short commit hash, the commit hashes {matched_commit_hashes:?} all start with the provided short commit hash {matching_oid_lowercase:?}.");
                }
            }
        }
        _ => git2::Oid::from_str(oid).context(format!("{oid:?} is not a valid commit hash.")),
    }
}
