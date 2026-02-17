use std::fmt::Write;

use super::{CommitError, CommitsError, LintingResults};

pub(crate) fn print_all(results: &LintingResults) -> String {
    let mut output = String::new();

    if let Some(commit_errors) = &results.commit_errors {
        for commit in &commit_errors.order {
            if let Some(errors) = commit_errors.errors.get(commit) {
                let short_hash = &commit.hash[..7.min(commit.hash.len())];
                let message = commit.message.lines().next().unwrap_or_default();

                let _ = writeln!(output, "::group::{short_hash} - {message}");

                for error in errors {
                    match error {
                        CommitError::MergeCommit => {
                            let _ = writeln!(
                                output,
                                "::error title=Merge Commit::Commit {short_hash} is a merge commit."
                            );
                        }
                    }
                }

                let _ = writeln!(output, "::endgroup::");
            }
        }
    }

    if let Some(commits_errors) = &results.commits_errors {
        for commits_error in &commits_errors.errors {
            match commits_error {
                CommitsError::MaxCommitsExceeded {
                    max_commits,
                    actual_commits,
                } => {
                    let _ = writeln!(
                        output,
                        "::error title=Max Commits Exceeded::Maximum commits exceeded: found {actual_commits} commits, but maximum allowed is {max_commits}."
                    );
                }
            }
        }
    }

    output
}
