use git2::{Oid, Repository};

pub(super) struct Commit {
    commit_hash: git2::Oid,
    number_of_parents: usize,
}

impl Commit {
    pub(super) fn new(repository: &Repository, oid: Oid) -> Result<Self, git2::Error> {
        let commit = repository.find_commit(oid)?;
        let number_of_parents = commit.parents().len();
        trace!(
            "The commit with the hash '{}' has {:?} parents.",
            commit.id(),
            number_of_parents,
        );

        Ok(Commit {
            commit_hash: commit.id(),
            number_of_parents,
        })
    }

    pub(super) fn is_merge_commit(&self) -> bool {
        let is_merge_commit = self.number_of_parents > 1;

        if is_merge_commit {
            warn!("Commit {:?} is a merge commit.", self.commit_hash);
        }

        is_merge_commit
    }
}

#[cfg(test)]
mod tests;
