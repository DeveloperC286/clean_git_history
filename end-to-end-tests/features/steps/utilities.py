import os

from subprocess import Popen, PIPE


def execute_command(command):
    process = Popen(
        command,
        shell=True,
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE)
    process.wait()

    result = type("Result", (), {})
    result.exit_code = process.returncode

    stdout, stderr = process.communicate()
    result.stdout = stdout.decode("utf-8")
    result.stderr = stderr.decode("utf-8")

    return result


def execute_clean_git_history(context):
    if "GIT_DIR" not in os.environ:
        os.chdir(context.remote_repository_cache)

    result = execute_command(f"{context.clean_git_history_path} {context.arguments} {context.from_ref}")

    if "GIT_DIR" not in os.environ:
        os.chdir(context.behave_directory)

    return result
