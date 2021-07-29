use std::process::exit;

use git2::{Oid, Repository};

pub struct Commit {
    commit_hash: git2::Oid,
    number_of_parents: usize,
}

impl Commit {
    pub fn from_git(repository: &Repository, oid: Oid) -> Self {
        match repository.find_commit(oid) {
            Ok(commit) => {
                let number_of_parents = commit.parents().len();
                trace!(
                    "Found {:?} partent for the commit with the hash '{}'.",
                    number_of_parents,
                    commit.id()
                );

                Commit {
                    commit_hash: commit.id(),
                    number_of_parents,
                }
            }
            Err(error) => {
                error!("{:?}", error);
                error!("Can not find commit with the hash '{}'.", oid);
                exit(crate::ERROR_EXIT_CODE);
            }
        }
    }

    pub fn is_merge_commit(&self) -> bool {
        let is_merge_commit = self.number_of_parents > 1;

        if is_merge_commit {
            warn!("Commit {:?} is a merge commit.", self.commit_hash);
        }

        is_merge_commit
    }
}
