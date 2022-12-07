import re
from behave import then

from utilities import execute_clean_git_history
from assertions import *


@then('the Git history is clean.')
def git_history_is_clean(context):
    # When
    execute_clean_git_history(context)

    # Then
    assert_empty(context.stdout)
    assert_empty(context.stderr)
    assert_successful(int(context.exit_code))


@then('the Git history is not clean.')
def git_history_is_not_clean(context):
    # When
    execute_clean_git_history(context)

    # Then
    assert_empty(context.stdout)
    assert_unsuccessful(int(context.exit_code))


@then('their is a could not find commit hash "{commit_hash}" error.')
def then_could_not_find_commit_hash_error(context, commit_hash):
    # Given
    could_not_find_commit_hash_error = f" ERROR clean_git_history_lib::commits > Can not find a commit with the hash '{commit_hash}'.\n"

    # When/Then
    git_history_is_not_clean(context)

    # Then
    assert_error(context.stderr, could_not_find_commit_hash_error)


@then('their is a could not find reference "{reference}" error.')
def then_could_not_find_reference_error(context, reference):
    # Given
    could_not_find_reference_error = f" ERROR clean_git_history_lib::commits > Could not find a reference with the name \"{reference}\".\n"

    # When/Then
    git_history_is_not_clean(context)

    # Then
    assert_error(context.stderr, could_not_find_reference_error)


@then(
    'their is a could not find shortened commit hash "{shortened_commit_hash}" error.')
def then_could_not_find_shortened_commit_hash_error(
        context, shortened_commit_hash):
    # Given
    could_not_find_shortened_commit_hash_error = f" ERROR clean_git_history_lib::commits > No actual commit hashes start with the provided short commit hash \"{shortened_commit_hash}\".\n"

    # When/Then
    git_history_is_not_clean(context)

    # Then
    assert_error(context.stderr, could_not_find_shortened_commit_hash_error)


@then(
    'their is a ambiguous shortened commit hash "{shortened_commit_hash}" error.')
def then_ambiguous_shortened_commit_hash_error(context, shortened_commit_hash):
    # Given
    ambiguous_shortened_commit_hash_error = re.compile(
        f"^ ERROR clean_git_history_lib::commits > Ambiguous short commit hash, the commit hashes [[]({shortened_commit_hash}[a-f0-9]*(, )?)*[]] all start with the provided short commit hash \"{shortened_commit_hash}\".\n$")

    # When/Then
    git_history_is_not_clean(context)

    # Then
    assert_regex(context.stderr, ambiguous_shortened_commit_hash_error)


@then('their is a conflicting from arguments error.')
def then_conflicting_from_arguments_error(context):
    # Given
    conflicting_arguments_end = "\n" + \
        "USAGE:\n" + \
        "    clean_git_history <--from-commit-hash <from-commit-hash>|--from-reference <from-reference>>\n" + \
        "\n" + \
        "For more information try --help\n"

    conflicting_from_commit_hash_error = f"error: The argument '--from-commit-hash <from-commit-hash>' cannot be used with one or more of the other specified arguments\n{conflicting_arguments_end}"
    conflicting_from_reference_error = f"error: The argument '--from-reference <from-reference>' cannot be used with one or more of the other specified arguments\n{conflicting_arguments_end}"

    # When/Then
    git_history_is_not_clean(context)

    # Then
    assert_in_errors(context.stderr, [
        conflicting_from_commit_hash_error,
        conflicting_from_reference_error])


@then('their is a missing from argument error.')
def then_missing_from_argument_error(context):
    # Given
    missing_from_argument_error = "error: The following required arguments were not provided:\n" + \
                                  "    <--from-commit-hash <from-commit-hash>|--from-reference <from-reference>>\n" + \
                                  "\n" + \
                                  "USAGE:\n" + \
                                  "    clean_git_history [FLAGS] [OPTIONS] <--from-commit-hash <from-commit-hash>|--from-reference <from-reference>>\n" + \
                                  "\n" + \
                                  "For more information try --help\n"

    # When/Then
    git_history_is_not_clean(context)

    # Then
    assert_error(context.stderr, missing_from_argument_error)
