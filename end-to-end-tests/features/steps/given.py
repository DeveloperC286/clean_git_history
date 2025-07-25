import os
import hashlib
from behave import given

from utilities import execute_command
from assertions import assert_command_successful


@given('the arguments are reset.')
def reset_arguments(context):
    context.arguments = ""
    context.from_ref = ""


def reset_context(context):
    context.behave_directory = os.getcwd()

    context.clean_git_history_path = f"{
        context.behave_directory}/../target/x86_64-unknown-linux-musl/debug/clean_git_history"
    reset_arguments(context)

    if "GIT_DIR" in os.environ:
        del os.environ["GIT_DIR"]


@given('the repository "{remote_repository}" is cloned and checked out at the commit "{commit_hash}".')
def clone_remote_repository_and_checkout_commit(context, remote_repository, commit_hash):
    reset_context(context)

    md5 = hashlib.md5(remote_repository.encode()).hexdigest()
    context.remote_repository_cache = f"/tmp/{md5}/{commit_hash}"

    if not os.path.exists(context.remote_repository_cache):
        result = execute_command(f"git clone {remote_repository} {context.remote_repository_cache}")
        assert_command_successful(result)

        os.chdir(context.remote_repository_cache)

        result = execute_command(f"git checkout {commit_hash}")
        assert_command_successful(result)

        os.chdir(context.behave_directory)


@given('the GIT_DIR environment variable is set to the cloned repository.')
def set_git_dir(context):
    os.environ["GIT_DIR"] = str(context.remote_repository_cache + "/.git")
