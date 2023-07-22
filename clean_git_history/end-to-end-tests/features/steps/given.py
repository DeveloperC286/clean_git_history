import os
import hashlib
from behave import given

from utilities import execute_command
from assertions import assert_successful


@given('the arguments are reset.')
def reset_arguments(context):
    context.arguments = ""


def reset_context(context):
    context.behave_directory = os.getcwd()

    context.pre_command = ""
    context.clean_git_history_path = f"{context.behave_directory}/../../target/debug/clean_git_history"
    reset_arguments(context)

    if "GIT_DIR" in os.environ:
        del os.environ["GIT_DIR"]


@given('the repository "{remote_repository}" is cloned and checked out at the commit "{commit_hash}".')
def clone_remote_repository_and_checkout_commit(
        context, remote_repository, commit_hash):
    reset_context(context)

    remote_repository_md5 = hashlib.md5(remote_repository.encode())
    context.remote_repository_cache = f"/tmp/{remote_repository_md5.hexdigest()}"

    if not os.path.exists(context.remote_repository_cache):
        (context.exit_code, _, _) = execute_command(
            f"git clone {remote_repository} {context.remote_repository_cache}")
        assert_successful(context)

    os.chdir(context.remote_repository_cache)

    (context.exit_code, _, _) = execute_command("git reset --hard origin/HEAD")
    assert_successful(context)

    (context.exit_code, _, _) = execute_command("git clean -fdx")
    assert_successful(context)

    (context.exit_code, _, _) = execute_command(f"git checkout {commit_hash}")
    assert_successful(context)

    os.chdir(context.behave_directory)


@given('the GIT_DIR environment variable is set to the cloned repository.')
def set_git_dir(context):
    os.environ["GIT_DIR"] = str(context.remote_repository_cache + "/.git")
