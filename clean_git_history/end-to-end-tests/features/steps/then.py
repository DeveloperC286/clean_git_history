import re
from behave import then

from utilities import execute_clean_git_history


@then('the Git history is clean.')
def git_history_is_clean(context):
    # When
    execute_clean_git_history(context)

    # Then
    assert context.stdout == ""
    assert context.stderr == ""
    assert int(context.exit_code) == 0


@then('the Git history is not clean.')
def git_history_is_not_clean(context):
    # When
    execute_clean_git_history(context)

    # Then
    assert context.stdout == ""
    assert int(context.exit_code) != 0


@then('their is a could not find commit hash "{commit_hash}" error.')
def then_could_not_find_commit_hash(context, commit_hash):
    # Given
    could_not_find_commit_hash_error = " ERROR clean_git_history_lib::commits > Can not find a commit with the hash '" + commit_hash + "'.\n"

    # When
    execute_clean_git_history(context)

    # Then
    assert context.stdout == ""
    assert int(context.exit_code) != 0
    assert context.stderr == could_not_find_commit_hash_error


@then('their is a could not find reference "{reference}" error.')
def then_could_not_find_reference(context, reference):
    # Given
    could_not_find_reference_error = " ERROR clean_git_history_lib::commits > Could not find a reference with the name \"" + \
                                     reference + "\".\n"

    # When
    execute_clean_git_history(context)
    # Then
    assert context.stdout == ""
    assert int(context.exit_code) != 0
    assert context.stderr == could_not_find_reference_error


@then(
    'their is a could not find shortened commit hash "{shortened_commit_hash}" error.')
def then_could_not_find_shortened_commit_hash(context, shortened_commit_hash):
    # Given
    could_not_find_shortened_commit_hash = " ERROR clean_git_history_lib::commits > No actual commit hashes start with the provided short commit hash \"" + \
        shortened_commit_hash + "\".\n"

    # When
    execute_clean_git_history(context)

    # Then
    assert context.stdout == ""
    assert int(context.exit_code) != 0
    assert context.stderr == could_not_find_shortened_commit_hash


@then(
    'their is a ambiguous shortened commit hash "{shortened_commit_hash}" error.')
def then_could_not_find_shortened_commit_hash(context, shortened_commit_hash):
    # Given
    ambiguous_shortened_commit_hash = re.compile(
        '^ ERROR clean_git_history_lib::commits > Ambiguous short commit hash, the commit hashes [[](' +
        shortened_commit_hash +
        '[a-f0-9]*(, )?)*[]] all start with the provided short commit hash "' +
        shortened_commit_hash +
        '".\n$')

    # When
    execute_clean_git_history(context)

    # Then
    assert context.stdout == ""
    assert int(context.exit_code) != 0
    assert ambiguous_shortened_commit_hash.match(context.stderr) is not None
