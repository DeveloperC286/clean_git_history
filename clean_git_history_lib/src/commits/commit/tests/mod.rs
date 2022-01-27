use std::collections::VecDeque;

use crate::commits::commit::Commit;
use crate::Commits;

#[test]
fn test_commits_contain_merge_commits() {
    // Given
    let commits = Commits {
        commits: VecDeque::from(vec![
            Commit {
                commit_hash: git2::Oid::from_str("1").unwrap(),
                number_of_parents: 1,
            },
            Commit {
                commit_hash: git2::Oid::from_str("2").unwrap(),
                number_of_parents: 2,
            },
            Commit {
                commit_hash: git2::Oid::from_str("3").unwrap(),
                number_of_parents: 2,
            },
        ]),
    };

    // When/Then
    assert!(commits.contains_merge_commits());
}

#[test]
fn test_commits_does_not_contain_merge_commits() {
    // Given
    let commits = Commits {
        commits: VecDeque::from(vec![
            Commit {
                commit_hash: git2::Oid::from_str("1").unwrap(),
                number_of_parents: 1,
            },
            Commit {
                commit_hash: git2::Oid::from_str("2").unwrap(),
                number_of_parents: 1,
            },
            Commit {
                commit_hash: git2::Oid::from_str("3").unwrap(),
                number_of_parents: 1,
            },
        ]),
    };

    // When/Then
    assert!(!commits.contains_merge_commits());
}
