import re
from behave import then

from utilities import execute_clean_git_history
from assertions import *


@then('the Git history is clean.')
def assert_git_history_is_clean(context):
    # When
    execute_clean_git_history(context)

    # Then
    assert_no_output(context)
    assert_no_errors(context)
    assert_command_successful(context)


@then('the Git history is not clean.')
def assert_git_history_is_not_clean(context):
    # When
    execute_clean_git_history(context)

    # Then
    assert_no_output(context)
    assert_command_unsuccessful(context)


@then('their is a could not find commit hash "{commit_hash}" error.')
def assert_could_not_find_commit_hash_error(context, commit_hash):
    # Given
    could_not_find_commit_hash_error = f" ERROR clean_git_history_lib::commits > Can not find a commit with the hash '{commit_hash}'.\n"

    # When/Then
    assert_git_history_is_not_clean(context)

    # Then
    assert_error_equals(context, could_not_find_commit_hash_error)


@then('their is a could not find reference "{reference}" error.')
def assert_could_not_find_reference_error(context, reference):
    # Given
    could_not_find_reference_error = f" ERROR clean_git_history_lib::commits > Could not find a reference with the name \"{reference}\".\n"

    # When/Then
    assert_git_history_is_not_clean(context)

    # Then
    assert_error_equals(context, could_not_find_reference_error)


@then(
    'their is a could not find shortened commit hash "{shortened_commit_hash}" error.')
def assert_could_not_find_shortened_commit_hash_error(
        context, shortened_commit_hash):
    # Given
    could_not_find_shortened_commit_hash_error = f" ERROR clean_git_history_lib::commits > No actual commit hashes start with the provided short commit hash \"{shortened_commit_hash}\".\n"

    # When/Then
    assert_git_history_is_not_clean(context)

    # Then
    assert_error_equals(context, could_not_find_shortened_commit_hash_error)


@then(
    'their is a ambiguous shortened commit hash "{shortened_commit_hash}" error.')
def assert_ambiguous_shortened_commit_hash_error(
        context, shortened_commit_hash):
    # Given
    ambiguous_shortened_commit_hash_error = re.compile(
        f"^ ERROR clean_git_history_lib::commits > Ambiguous short commit hash, the commit hashes [[]({shortened_commit_hash}[a-f0-9]*(, )?)*[]] all start with the provided short commit hash \"{shortened_commit_hash}\".\n$")

    # When/Then
    assert_git_history_is_not_clean(context)

    # Then
    assert_error_matches_regex(context, ambiguous_shortened_commit_hash_error)


@then('their is a conflicting from arguments error.')
def assert_conflicting_from_arguments_error(context):
    # Given
    conflicting_arguments_end = "\n" + \
        "Usage: clean_git_history <--from-commit-hash <FROM_COMMIT_HASH>|--from-reference <FROM_REFERENCE>>\n" + \
        "\n" + \
        "For more information, try '--help'.\n"
    conflicting_from_commit_hash_error = f"error: the argument '--from-commit-hash <FROM_COMMIT_HASH>' cannot be used with '--from-reference <FROM_REFERENCE>'\n{conflicting_arguments_end}"
    conflicting_from_reference_error = f"error: the argument '--from-reference <FROM_REFERENCE>' cannot be used with '--from-commit-hash <FROM_COMMIT_HASH>'\n{conflicting_arguments_end}"

    # When/Then
    assert_git_history_is_not_clean(context)

    # Then
    assert_error_is_one_of(context, [
        conflicting_from_commit_hash_error,
        conflicting_from_reference_error])


@then('their is a missing from argument error.')
def assert_missing_from_argument_error(context):
    # Given
    missing_from_argument_error = "error: the following required arguments were not provided:\n" + \
                                  "  <--from-commit-hash <FROM_COMMIT_HASH>|--from-reference <FROM_REFERENCE>>\n" + \
                                  "\n" + \
                                  "Usage: clean_git_history <--from-commit-hash <FROM_COMMIT_HASH>|--from-reference <FROM_REFERENCE>>\n" \
                                  "\n" + \
                                  "For more information, try '--help'.\n"

    # When/Then
    assert_git_history_is_not_clean(context)

    # Then
    assert_error_equals(context, missing_from_argument_error)
