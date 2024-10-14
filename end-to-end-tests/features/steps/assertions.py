def assert_command_successful(result):
    assert result.exit_code == 0, "Expected a zero exit code to indicate a successful execution.\n" + \
        f"Exit code = '{result.exit_code}'.\n"


def assert_command_unsuccessful(result):
    assert result.exit_code != 0, "Expected a non-zero exit code to indicate a unsuccessful execution\n" + \
        f"Exit code = '{result.exit_code}'.\n"


def assert_no_output(result):
    assert result.stdout == "", "Expected standard output to be empty.\n" + \
        f"Standard output = {result.stdout.encode()}.\n"


def assert_no_errors(result):
    assert result.stderr == "", "Expected standard error to be empty.\n" + \
        f"Standard error = {result.stderr.encode()}.\n"


def assert_error_equals(result, error):
    assert result.stderr == error, "Expected standard error to equal the error.\n" + \
        f"Standard error = {result.stderr.encode()}.\n" + \
        f"Error          = {error.encode()}.\n"


def assert_error_matches_regex(result, regex):
    assert regex.match(result.stderr) is not None, f"Expected standard errors to match the regex.\n" + \
        f"Standard error = {result.stderr.encode()}.\n" + \
        f"Regex          = {regex.pattern.encode()}.\n"


def assert_error_is_one_of(result, errors):
    assert result.stderr in errors, "Expected standard error to equal one of these errors.\n" + \
        f"Standard error = {result.stderr.encode()}.\n" + \
        f"Errors         = {errors}.\n"
