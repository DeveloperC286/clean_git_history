use std::fmt::Write;

use anstyle::{AnsiColor, Color, Style};

use super::{CommitError, CommitsError, LintingResults};

const RED: Style = Style::new()
    .bold()
    .fg_color(Some(Color::Ansi(AnsiColor::Red)));

pub(crate) fn print_all(results: &LintingResults) -> String {
    let mut output = String::new();

    // Print per-commit errors
    if let Some(commit_errors) = &results.commit_errors {
        for commit in &commit_errors.order {
            if let Some(errors) = commit_errors.errors.get(commit) {
                let _ = writeln!(output, "{RED}Commit Hash{RED:#} - {}", commit.short_hash());
                let _ = writeln!(output, "{RED}Message{RED:#} - {:?}", commit.message);

                for error in errors {
                    match error {
                        CommitError::MergeCommit => {
                            let _ = writeln!(output, "\t{RED}X{RED:#} - Commit is a merge commit.");
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
            "{RED}X{RED:#} - Found {total_linting_errors} separate linting errors across {} commits.",
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
                        "{RED}X{RED:#} - Maximum commits exceeded: found {actual_commits} commits, but maximum allowed is {max_commits}."
                    );
                }
            }
        }
    }

    output
}
