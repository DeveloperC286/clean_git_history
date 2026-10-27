import os
from subprocess import PIPE, Popen

# Environment variables which change clean_git_history's behaviour, they are scrubbed from the inherited environment so
# scenarios are isolated from the environment behave itself is running in (e.g. GitHub Actions).
SCRUBBED_ENVIRONMENT_VARIABLES = ["GIT_DIR", "GITHUB_ACTIONS", "CI", "RUST_BACKTRACE", "RUST_LIB_BACKTRACE"]


def execute_command(command, cwd=None, environment_overrides=None):
    environment = os.environ.copy()

    for variable in SCRUBBED_ENVIRONMENT_VARIABLES:
        environment.pop(variable, None)

    environment.update(environment_overrides or {})

    process = Popen(
        command,
        shell=True,
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE,
        cwd=cwd,
        env=environment)
    process.wait()

    result = type("Result", (), {})
    result.exit_code = process.returncode

    stdout, stderr = process.communicate()
    result.stdout = stdout.decode("utf-8")
    result.stderr = stderr.decode("utf-8")

    return result


def execute_clean_git_history(context):
    cwd = None
    if "GIT_DIR" not in context.environment_overrides:
        cwd = context.remote_repository_cache

    return execute_command(
        f"{context.clean_git_history_path} {context.arguments} {context.from_ref}",
        cwd=cwd,
        environment_overrides=context.environment_overrides)
