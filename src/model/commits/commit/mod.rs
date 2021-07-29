use std::process::exit;

use git2::{Oid, Repository};

pub struct Commit {
    _message: String,
}

impl Commit {
    pub fn from_git(repository: &Repository, oid: Oid) -> Option<Self> {
        match repository.find_commit(oid) {
            Ok(commit) => match commit.message().map(|m| m.to_string()) {
                Some(message) => {
                    trace!(
                        "Found the commit message {:?} for the commit with the hash '{}'.",
                        message,
                        commit.id()
                    );

                    Some(Commit { _message: message })
                }
                None => {
                    error!(
                        "Can not find commit message for the commit with the hash '{}'.",
                        oid
                    );
                    None
                }
            },
            Err(error) => {
                error!("{:?}", error);
                error!("Can not find commit with the hash '{}'.", oid);
                exit(crate::ERROR_EXIT_CODE);
            }
        }
    }
}
