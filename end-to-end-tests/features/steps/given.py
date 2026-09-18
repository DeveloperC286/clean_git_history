import atexit
import os
import re
import shutil
import tarfile
import tempfile

from assertions import assert_command_successful
from behave import given
from utilities import execute_command

FIXTURES_DIRECTORY = os.path.join(
    os.path.dirname(
        os.path.abspath(__file__)),
    "..",
    "..",
    "fixtures")

# Environment variables that leak into the output being asserted upon, so they
# are scrubbed rather than inherited from whoever is running the suite.
SCRUBBED_ENVIRONMENT_VARIABLES = [
    "GIT_DIR",
    "GITHUB_ACTIONS",
    "CI",
    "RUST_BACKTRACE",
    "RUST_LOG",
]

# Fixtures are unpacked once per run and shared between the scenarios using them.
_unpacked_fixtures = {}
_unpacked_fixtures_directory = None


@given('the arguments are reset.')
def reset_arguments(context):
    context.arguments = ""
    context.from_ref = ""


def reset_context(context):
    context.behave_directory = os.getcwd()

    context.clean_git_history_path = f"{
        context.behave_directory}/../target/debug/clean_git_history"
    reset_arguments(context)

    for variable in SCRUBBED_ENVIRONMENT_VARIABLES:
        if variable in os.environ:
            del os.environ[variable]


def get_fixture_slug(remote_repository):
    slug = re.sub(r"^https?://", "", remote_repository)
    slug = re.sub(r"\.git$", "", slug)
    return slug.replace("/", "-")


def unpack_fixture(slug, destination):
    global _unpacked_fixtures_directory

    if _unpacked_fixtures_directory is None:
        _unpacked_fixtures_directory = tempfile.mkdtemp(prefix="clean_git_history-")
        atexit.register(shutil.rmtree, _unpacked_fixtures_directory, True)

    repository = os.path.join(_unpacked_fixtures_directory, destination)

    with tarfile.open(os.path.join(FIXTURES_DIRECTORY, f"{slug}.tar.gz")) as fixture:
        fixture.extractall(repository, filter="data")

    return repository


@given('the repository "{remote_repository}" is at the commit "{commit_hash}".')
def checkout_fixture_at_commit(context, remote_repository, commit_hash):
    reset_context(context)

    slug = get_fixture_slug(remote_repository)

    if (slug, commit_hash) not in _unpacked_fixtures:
        repository = unpack_fixture(slug, f"{slug}-{commit_hash}")

        # The fixture ships without a checked out commit, as which commit it is
        # read from is the scenario's to decide.
        result = execute_command(
            f"git --git-dir={repository}/.git update-ref --no-deref HEAD {commit_hash}")
        assert_command_successful(result)

        _unpacked_fixtures[(slug, commit_hash)] = repository

    context.repository_directory = _unpacked_fixtures[(slug, commit_hash)]


@given('the GIT_DIR environment variable is set to the repository.')
def set_git_dir(context):
    os.environ["GIT_DIR"] = str(context.repository_directory + "/.git")


@given('the GITHUB_ACTIONS environment variable is set.')
def set_github_actions(context):
    os.environ["GITHUB_ACTIONS"] = "true"
    os.environ["CI"] = "true"
