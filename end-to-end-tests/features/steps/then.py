import re

from assertions import (
    assert_command_successful,
    assert_command_unsuccessful,
    assert_error_contains,
    assert_error_matches_regex,
    assert_no_errors,
    assert_no_output,
    assert_output_contains,
    assert_output_does_not_contain,
)
from behave import then
from utilities import execute_clean_git_history


@then('the Git history is clean.')
def assert_git_history_is_clean(context):
    # When
    result = execute_clean_git_history(context)

    # Then
    assert_no_output(result)
    assert_no_errors(result)
    assert_command_successful(result)


@then('the Git history is not clean.')
def assert_git_history_is_not_clean(context):
    # When
    result = execute_clean_git_history(context)

    # Then
    assert_command_unsuccessful(result)
    return result


@then('their is a could not find commit hash "{commit_hash}" error.')
def assert_could_not_find_commit_hash_error(context, commit_hash):
    # Given
    could_not_find_commit_hash_error = f"Can not find a commit with the hash '{commit_hash}'.\n"  # fmt: off

    # When/Then
    result = assert_git_history_is_not_clean(context)

    # Then
    assert_error_contains(result, could_not_find_commit_hash_error)


@then('their is a could not find reference "{reference}" error.')
def assert_could_not_find_reference_error(context, reference):
    # Given
    could_not_find_reference_error = f"Could not find a reference with the name \"{reference}\".\n"  # fmt: off

    # When/Then
    result = assert_git_history_is_not_clean(context)

    # Then
    assert_error_contains(result, could_not_find_reference_error)


@then('their is a could not find shortened commit hash "{shortened_commit_hash}" error.')
def assert_could_not_find_shortened_commit_hash_error(context, shortened_commit_hash):
    # Given
    could_not_find_shortened_commit_hash_error = f"No actual commit hashes start with the provided short commit hash \"{shortened_commit_hash}\".\n"  # fmt: off

    # When/Then
    result = assert_git_history_is_not_clean(context)

    # Then
    assert_error_contains(result, could_not_find_shortened_commit_hash_error)


@then('their is a ambiguous shortened commit hash "{shortened_commit_hash}" error.')
def assert_ambiguous_shortened_commit_hash_error(context, shortened_commit_hash):
    # Given
    ambiguous_shortened_commit_hash_error = re.compile(f"^ ERROR clean_git_history > Could not find a reference with the name \"{shortened_commit_hash}\".\n\nCaused by:\n    Ambiguous short commit hash, the commit hashes [[]({shortened_commit_hash}[a-f0-9]*(, )?)*[]] all start with the provided short commit hash \"{shortened_commit_hash}\".\n$")  # fmt: off

    # When/Then
    result = assert_git_history_is_not_clean(context)

    # Then
    assert_error_matches_regex(result, ambiguous_shortened_commit_hash_error)


@then('their is a no commits within the provided range error.')
def assert_no_commits_within_the_provided_range_error(context):
    # Given
    no_commits_within_the_provided_range_error = "No Git commits within the provided range.\n"  # fmt: off

    # When/Then
    result = assert_git_history_is_not_clean(context)

    # Then
    assert_error_contains(result, no_commits_within_the_provided_range_error)


@then('their is a too short commit hash "{shortened_commit_hash}" error.')
def assert_too_short_commit_hash_error(context, shortened_commit_hash):
    # Given
    too_short_commit_hash_error = f"The provided short commit hash \"{shortened_commit_hash}\" is shorter than the minimum of 4 characters.\n"  # fmt: off

    # When/Then
    result = assert_git_history_is_not_clean(context)

    # Then
    assert_error_contains(result, too_short_commit_hash_error)


@then('their is an ambiguous reference and commit hash warning for "{ambiguous}".')
def assert_ambiguous_reference_and_commit_hash_warning(context, ambiguous):
    # Given
    ambiguous_reference_and_commit_hash_warning = f"The provided \"{ambiguous}\" is ambiguous, it is both a reference pointing at the commit "  # fmt: off

    # When
    result = execute_clean_git_history(context)

    # Then
    assert_error_contains(result, ambiguous_reference_and_commit_hash_warning)


@then('their is an ambiguous full commit hash and reference warning for "{ambiguous}".')
def assert_ambiguous_full_commit_hash_and_reference_warning(context, ambiguous):
    # Given
    ambiguous_full_commit_hash_and_reference_warning = f"The provided \"{ambiguous}\" is ambiguous, it is both a full commit hash and the reference "  # fmt: off

    # When
    result = execute_clean_git_history(context)

    # Then
    assert_error_contains(result, ambiguous_full_commit_hash_and_reference_warning)


@then('their is an ambiguous references warning for "{ambiguous}".')
def assert_ambiguous_references_warning(context, ambiguous):
    # Given
    ambiguous_references_warning = f"The provided \"{ambiguous}\" is ambiguous, it matches the references "  # fmt: off

    # When
    result = execute_clean_git_history(context)

    # Then
    assert_error_contains(result, ambiguous_references_warning)


@then('their is an invalid max commits value "{max_commits}" error.')
def assert_invalid_max_commits_value_error(context, max_commits):
    # Given
    invalid_max_commits_value_error = f"error: invalid value '{max_commits}' for '--max-commits <MAX_COMMITS>'"  # fmt: off

    # When/Then
    result = assert_git_history_is_not_clean(context)

    # Then
    assert_error_contains(result, invalid_max_commits_value_error)


@then('the GitHub Actions output contains a merge commit error.')
def assert_github_output_contains_merge_commit_error(context):
    result = execute_clean_git_history(context)
    assert_command_unsuccessful(result)
    assert_output_contains(result, "::error title=Merge Commit::")
    assert_output_contains(result, "::group::")
    assert_output_contains(result, "::endgroup::")


@then('the pretty output contains a merge commit error.')
def assert_pretty_output_contains_merge_commit_error(context):
    result = execute_clean_git_history(context)
    assert_command_unsuccessful(result)
    assert_output_contains(result, "Commit Hash")
    assert_output_does_not_contain(result, "::error")
