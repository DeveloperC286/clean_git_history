#[macro_use]
extern crate log;

use git2::{Oid, Repository, Revwalk};

use crate::commit::Commit;
use std::collections::VecDeque;

mod commit;

pub struct Commits {
    commits: VecDeque<Commit>,
}

impl Commits {
    pub fn from_reference(from_reference: String) -> Result<Self, git2::Error> {
        let repository = get_repository()?;
        let reference_oid = get_reference_oid(&repository, &from_reference)?;
        get_commits_till_head_from_oid(&repository, reference_oid)
    }

    pub fn from_commit_hash(from_commit_hash: String) -> Result<Self, git2::Error> {
        let repository = get_repository()?;
        let commit_oid = parse_to_oid(&repository, from_commit_hash)?;
        get_commits_till_head_from_oid(&repository, commit_oid)
    }

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

        match Commit::new(repository, oid) {
            Ok(commit) => commits.push_front(commit),
            Err(error) => {
                error!("Can not find a commit with the hash '{}'.", oid);
                return Err(error);
            }
        }
    }

    Ok(Commits { commits })
}

fn get_repository() -> Result<Repository, git2::Error> {
    match Repository::open_from_env() {
        Ok(repository) => Ok(repository),
        Err(error) => {
            error!("Failed to open a Git repository from the current directory or Git environment variables.");
            Err(error)
        }
    }
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

fn parse_to_oid(repository: &Repository, oid: String) -> Result<Oid, git2::Error> {
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
        _ => match git2::Oid::from_str(&oid) {
            Ok(oid) => Ok(oid),
            Err(error) => {
                error!("{:?} is not a valid commit hash.", oid);
                Err(error)
            }
        },
    }
}
