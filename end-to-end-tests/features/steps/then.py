import os
from behave import then

from utilities import execute_clean_git_history


@then('the Git history is clean.')
def git_history_is_clean(context):
    execute_clean_git_history(context)
    assert context.stdout == ""
    assert context.stderr == ""
    assert int(context.exit_code) == 0


@then('the Git history is not clean.')
def git_history_is_not_clean(context):
    execute_clean_git_history(context)
    assert context.stdout == ""
    assert int(context.exit_code) != 0


@then('their is a could not find commit hash "{commit_hash}" error.')
def then_could_not_find_commit_hash(context, commit_hash):
    execute_clean_git_history(context)
    could_not_find_commit_hash_error = " ERROR clean_git_history::model::commits > Can not find commit hash '" + \
        commit_hash + "' on the Git revision walker.\n"
    assert context.stdout == ""
    assert int(context.exit_code) != 0
    assert context.stderr == could_not_find_commit_hash_error
