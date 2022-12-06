def assert_successful(exit_code):
    assert exit_code == 0, f"Expected a zero exit code to indicate a successful execution, got '{exit_code}'."


def assert_unsuccessful(exit_code):
    assert exit_code != 0, f"Expected a non-zero exit code to indicate a unsuccessful execution, got '{exit_code}'."


def assert_empty(output):
    assert output == "", f"Expected the output to be empty, got:\n{output.encode()}"
