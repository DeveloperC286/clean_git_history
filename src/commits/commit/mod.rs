use std::borrow::Cow;

use log::{debug, trace, warn};

use crate::linting_results::CommitError;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Commit {
    pub hash: String,
    pub message: String,
    number_of_parents: usize,
}

impl Commit {
    pub(super) fn from_git(commit: &git2::Commit) -> Commit {
        let number_of_parents = commit.parents().len();

        // Commit messages are only bytes, so are not guaranteed to be valid UTF-8. Legacy
        // histories, such as those imported from CVS/SVN, can carry other encodings. None of
        // the lints inspect the message's content, so lossily convert rather than aborting the
        // whole run over a single commit.
        let message = match String::from_utf8_lossy(commit.message_bytes()) {
            Cow::Borrowed(message) => message.to_string(),
            Cow::Owned(message) => {
                warn!(
                    "The commit message for the commit with the hash '{}' is not valid UTF-8, the invalid sequences have been replaced.",
                    commit.id()
                );
                message
            }
        };

        trace!(
            "Found the commit message {message:?} for the commit with the hash '{}'.",
            commit.id()
        );

        debug!(
            "The commit with the hash '{}' has {:?} parents.",
            commit.id(),
            number_of_parents,
        );

        Commit {
            hash: commit.id().to_string(),
            message,
            number_of_parents,
        }
    }

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

#[cfg(test)]
mod tests {
    use std::path::PathBuf;

    use git2::{ObjectType, Oid, Repository};

    use super::*;

    /// A bare repository within a uniquely named temporary directory, removed once dropped.
    struct TemporaryRepository {
        path: PathBuf,
        repository: Repository,
    }

    impl TemporaryRepository {
        fn new(name: &str) -> TemporaryRepository {
            let path = std::env::temp_dir()
                .join(format!("clean_git_history-{}-{name}", std::process::id()));
            // Remove any remnants of a previously aborted run.
            let _ = std::fs::remove_dir_all(&path);
            let repository = Repository::init_bare(&path).unwrap();

            TemporaryRepository { path, repository }
        }

        /// Writes a commit object with the provided raw message bytes.
        ///
        /// git2's commit creation API only accepts a UTF-8 `&str` message, so the object is
        /// assembled by hand to be able to produce the messages of any encoding which real
        /// world histories contain.
        fn write_commit(
            &self,
            parents: &[Oid],
            encoding: Option<&str>,
            message: &[u8],
        ) -> git2::Commit<'_> {
            let tree = self.repository.treebuilder(None).unwrap().write().unwrap();

            let mut object = format!("tree {tree}\n").into_bytes();

            for parent in parents {
                object.extend_from_slice(format!("parent {parent}\n").as_bytes());
            }

            object.extend_from_slice(b"author T <t@t.t> 0 +0000\n");
            object.extend_from_slice(b"committer T <t@t.t> 0 +0000\n");

            if let Some(encoding) = encoding {
                object.extend_from_slice(format!("encoding {encoding}\n").as_bytes());
            }

            object.extend_from_slice(b"\n");
            object.extend_from_slice(message);

            let oid = self
                .repository
                .odb()
                .unwrap()
                .write(ObjectType::Commit, &object)
                .unwrap();
            self.repository.find_commit(oid).unwrap()
        }
    }

    impl Drop for TemporaryRepository {
        fn drop(&mut self) {
            let _ = std::fs::remove_dir_all(&self.path);
        }
    }

    #[test]
    fn from_git_reads_a_utf8_message_unaltered() {
        // Given
        let repository = TemporaryRepository::new("from_git_reads_a_utf8_message_unaltered");
        let commit = repository.write_commit(&[], None, "Añadir el fichero b\n".as_bytes());

        // When
        let commit = Commit::from_git(&commit);

        // Then
        assert_eq!("Añadir el fichero b\n", commit.message);
    }

    #[test]
    fn from_git_lossily_replaces_an_invalid_utf8_message() {
        // Given
        let repository =
            TemporaryRepository::new("from_git_lossily_replaces_an_invalid_utf8_message");
        // "Créer le fichier b\n" encoded as ISO-8859-1, so the 0xE9 byte is not valid UTF-8.
        let commit = repository.write_commit(
            &[],
            Some("ISO-8859-1"),
            b"Cr\xe9er le fichier b\n".as_slice(),
        );

        // When
        let commit = Commit::from_git(&commit);

        // Then
        assert_eq!("Cr\u{fffd}er le fichier b\n", commit.message);
    }

    #[test]
    fn lint_detects_a_merge_commit_with_an_invalid_utf8_message() {
        // Given
        let repository =
            TemporaryRepository::new("lint_detects_a_merge_commit_with_an_invalid_utf8_message");
        let first_parent = repository.write_commit(&[], None, b"First parent.\n".as_slice());
        let second_parent = repository.write_commit(&[], None, b"Second parent.\n".as_slice());
        let commit = repository.write_commit(
            &[first_parent.id(), second_parent.id()],
            Some("ISO-8859-1"),
            b"Fusionn\xe9 la branche side\n".as_slice(),
        );

        // When
        let errors = Commit::from_git(&commit).lint();

        // Then
        assert_eq!(vec![CommitError::MergeCommit], errors);
    }
}
