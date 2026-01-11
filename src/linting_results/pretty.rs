use std::fmt::Write;

use ansi_term::Colour::Red;

use super::{CommitError, CommitsError, LintingResults};

pub(crate) fn print_all(results: &LintingResults) -> String {
    let mut output = String::new();
    let red = Red.bold();

    // Print per-commit errors
    if let Some(commit_errors) = &results.commit_errors {
        for commit in &commit_errors.order {
            if let Some(errors) = commit_errors.errors.get(commit) {
                let _ = writeln!(output, "{} - {}", red.paint("Commit Hash"), commit.hash);
                let _ = writeln!(output, "{} - {:?}", red.paint("Message"), commit.message);

                for error in errors {
                    match error {
                        CommitError::MergeCommit => {
                            let _ = writeln!(
                                output,
                                "\t{} - Commit is a merge commit.",
                                red.paint("X")
                            );
                        }
                    }
                }

                let _ = writeln!(output);
            }
        }

        // Print summary of commit errors
        let total_linting_errors: usize = commit_errors.errors.values().map(|x| x.len()).sum();

        let _ = writeln!(
            output,
            "{} - Found {total_linting_errors} separate linting errors across {} commits.",
            red.paint("X"),
            commit_errors.errors.len()
        );
    }

    // Print aggregate errors
    if let Some(commits_errors) = &results.commits_errors {
        for commits_error in &commits_errors.errors {
            match commits_error {
                CommitsError::MaxCommitsExceeded {
                    max_commits,
                    actual_commits,
                } => {
                    let _ = writeln!(
                        output,
                        "{} - Maximum commits exceeded: found {} commits, but maximum allowed is {}.",
                        red.paint("X"),
                        actual_commits,
                        max_commits
                    );
                }
            }
        }
    }

    output
}
