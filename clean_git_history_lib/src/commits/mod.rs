use std::collections::VecDeque;

use git2::{Oid, Repository, Revwalk};

use crate::commits::commit::Commit;

mod commit;

/// A representation of a range of commits within a Git repository, which can have various lints performed upon it after construction.
pub struct Commits {
    commits: VecDeque<Commit>,
}

impl Commits {
    /// Create a new range of commits from a reference exclusively from the commit specified by the reference till inclusively of `HEAD`.
    ///
    /// Supports providing either the full or short name of the reference.
    ///
    /// E.g. short name.
    ///
    /// ```
    /// use git2::Repository;
    /// use clean_git_history_lib::Commits;
    ///
    /// let repository = Repository::open_from_env().unwrap();
    /// let commits = Commits::from_reference(&repository, "v1.0.0");
    /// ```
    ///
    /// E.g. full name.
    ///
    /// ```
    /// use git2::Repository;
    /// use clean_git_history_lib::Commits;
    ///
    /// let repository = Repository::open_from_env().unwrap();
    /// let commits = Commits::from_reference(&repository, "refs/tags/v1.0.0");
    /// ```
    pub fn from_reference<T: AsRef<str>>(
        repository: &Repository,
        reference: T,
    ) -> Result<Commits, git2::Error> {
        let reference_oid = get_reference_oid(repository, reference.as_ref())?;
        get_commits_till_head_from_oid(repository, reference_oid)
    }

    /// Create a new range of commits from a commit hash exclusively from the commit specified till inclusively of `HEAD`.
    ///
    /// Supports providing either the full commit hash or a shortened commit hash.
    ///
    /// E.g. shortened commit hash.
    ///
    /// ```
    /// use git2::Repository;
    /// use clean_git_history_lib::Commits;
    ///
    /// let repository = Repository::open_from_env().unwrap();
    /// let commits = Commits::from_commit_hash(&repository, "d58f1598");
    /// ```
    ///
    /// E.g. full commit hash.
    ///
    /// ```
    /// use git2::Repository;
    /// use clean_git_history_lib::Commits;
    ///
    /// let repository = Repository::open_from_env().unwrap();
    /// let commits = Commits::from_commit_hash(&repository, "d58f159849a1551dbe7f67019208c2e0de08da80");
    /// ```
    pub fn from_commit_hash<T: AsRef<str>>(
        repository: &Repository,
        commit_hash: T,
    ) -> Result<Commits, git2::Error> {
        let commit_oid = parse_to_oid(repository, commit_hash.as_ref())?;
        get_commits_till_head_from_oid(repository, commit_oid)
    }

    /// A lint that can be performed on the range of commits, which returns true if any of the
    /// commits are merge commits, i.e. has multiple parents.
    pub fn contains_merge_commits(&self) -> bool {
        self.commits
            .iter()
            .map(|commit| commit.is_merge_commit())
            .any(|is_merge_commit| is_merge_commit)
    }
}

fn get_commits_till_head_from_oid(
    repository: &Repository,
    from_commit_hash: Oid,
) -> Result<Commits, git2::Error> {
    fn get_revwalker(
        repository: &Repository,
        from_commit_hash: Oid,
    ) -> Result<Revwalk, git2::Error> {
        let mut commits = repository.revwalk()?;
        commits.simplify_first_parent()?;
        commits.push_head()?;

        match commits.hide(from_commit_hash) {
            Ok(_) => Ok(commits),
            Err(error) => {
                error!(
                    "Can not find a commit with the hash '{}'.",
                    from_commit_hash
                );
                Err(error)
            }
        }
    }

    let revwalker = get_revwalker(repository, from_commit_hash)?;
    let mut commits = VecDeque::new();

    for commit in revwalker {
        let oid = commit?;

        match Commit::from_git(repository, oid) {
            Ok(commit) => commits.push_front(commit),
            Err(error) => {
                error!("Can not find a commit with the hash '{}'.", oid);
                return Err(error);
            }
        }
    }

    Ok(Commits { commits })
}

fn get_reference_oid(repository: &Repository, matching: &str) -> Result<Oid, git2::Error> {
    match repository.resolve_reference_from_short_name(matching) {
        Ok(reference) => {
            trace!(
                "Matched {:?} to the reference {:?}.",
                matching,
                reference.name().unwrap()
            );
            let commit = reference.peel_to_commit()?;
            Ok(commit.id())
        }
        Err(error) => {
            error!("Could not find a reference with the name {:?}.", matching);
            Err(error)
        }
    }
}

fn parse_to_oid(repository: &Repository, oid: &str) -> Result<Oid, git2::Error> {
    match oid.len() {
        1..=39 => {
            trace!(
                "Attempting to find a match for the short commit hash {:?}.",
                oid
            );
            let matching_oid_lowercase = oid.to_lowercase();

            let mut revwalker = repository.revwalk()?;
            revwalker.push_head()?;

            let matched_commit_hashes: Vec<Oid> = revwalker
                .into_iter()
                .map(|result| {
                    return match result {
                        Ok(oid) => {
                            let oid_lowercase = oid.to_string().to_lowercase();

                            if oid_lowercase.starts_with(&matching_oid_lowercase) {
                                return Some(oid);
                            }

                            None
                        }
                        Err(error) => {
                            error!("{:?}", error);

                            None
                        }
                    };
                })
                .flatten()
                .collect();

            match matched_commit_hashes.len() {
                0 => {
                    error!(
                        "No actual commit hashes start with the provided short commit hash {:?}.",
                        matching_oid_lowercase
                    );
                    Err(git2::Error::from_str(""))
                }
                1 => Ok(*matched_commit_hashes.first().unwrap()),
                _ => {
                    error!("Ambiguous short commit hash, the commit hashes {:?} all start with the provided short commit hash {:?}.", matched_commit_hashes, matching_oid_lowercase);
                    Err(git2::Error::from_str(""))
                }
            }
        }
        _ => match git2::Oid::from_str(oid) {
            Ok(oid) => Ok(oid),
            Err(error) => {
                error!("{:?} is not a valid commit hash.", oid);
                Err(error)
            }
        },
    }
}
