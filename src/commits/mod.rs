use std::collections::VecDeque;

use anyhow::{Context, Result, bail};
use git2::{Oid, Repository, Revwalk};
use log::{debug, info, warn};

use crate::linting_results::{CommitErrors, CommitsError, CommitsErrors, LintingResults};

pub mod commit;
pub use commit::Commit;

/// A representation of a range of commits within a Git repository, which can have various lints performed upon it after construction.
pub struct Commits {
    commits: VecDeque<Commit>,
}

impl Commits {
    pub fn from_git<T: AsRef<str>>(repository: &Repository, git: T) -> Result<Commits> {
        let oid = resolve_to_oid(repository, git.as_ref())?;
        get_commits_till_head_from_oid(repository, oid)
    }

    /// Lint all commits and return the linting results if any issues are found.
    pub fn lint(&self, max_commits: Option<usize>) -> Option<LintingResults> {
        // Check each commit for linting errors, retaining the order they were walked in
        let commit_errors = CommitErrors::new(
            self.commits
                .iter()
                .filter_map(|commit| {
                    let errors = commit.lint();

                    if errors.is_empty() {
                        return None;
                    }

                    warn!(
                        "Found {} linting errors for the commit {:?}.",
                        errors.len(),
                        commit.hash
                    );
                    Some((commit.clone(), errors))
                })
                .collect(),
        );

        // Check for aggregate errors
        let actual_commits = self.commits.len();
        let commits_errors = CommitsErrors::new(match max_commits {
            Some(max_commits) if actual_commits > max_commits => {
                vec![CommitsError::MaxCommitsExceeded {
                    max_commits,
                    actual_commits,
                }]
            }
            _ => Vec::new(),
        });

        LintingResults::new(commit_errors, commits_errors)
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
        let commit = Commit::from_git(&commit)?;
        commits.push_front(commit);
    }

    if commits.is_empty() {
        bail!("No Git commits within the provided range.");
    }

    info!("Found {} commits within the provided range.", commits.len());
    Ok(Commits { commits })
}

/// Resolve to the Oid of a commit, preferring a reference over a commit hash as Git itself does.
fn resolve_to_oid(repository: &Repository, git: &str) -> Result<Oid> {
    match get_reference_oid(repository, git) {
        Ok(reference_oid) => {
            // Git resolves an ambiguous name to the reference, only warning that the name is also a commit hash.
            if let Ok(commit_oid) = parse_to_oid(repository, git)
                && commit_oid != reference_oid
            {
                warn!(
                    "The provided {git:?} is ambiguous, it is both a reference pointing at the commit '{reference_oid}' and the commit hash '{commit_oid}', using the reference as Git does."
                );
            }

            info!("Using the reference {git:?}, which points at the commit '{reference_oid}'.");
            Ok(reference_oid)
        }
        Err(reference_error) => {
            let commit_oid =
                parse_to_oid(repository, git).map_err(|error| error.context(reference_error))?;
            info!("Using the commit hash '{commit_oid}'.");
            Ok(commit_oid)
        }
    }
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
    // Avoid searching the history for anything which can not be a commit hash, such as a reference's name.
    if oid.is_empty() || !oid.chars().all(|character| character.is_ascii_hexdigit()) {
        bail!("{oid:?} is not a valid commit hash.");
    }

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
                    bail!(
                        "Ambiguous short commit hash, the commit hashes {matched_commit_hashes:?} all start with the provided short commit hash {matching_oid_lowercase:?}."
                    );
                }
            }
        }
        _ => git2::Oid::from_str(oid).context(format!("{oid:?} is not a valid commit hash.")),
    }
}
