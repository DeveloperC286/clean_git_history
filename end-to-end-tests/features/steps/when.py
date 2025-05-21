from behave import when


@when('linting from the "{git}".')
def set_linting_from_the(context, git):
    context.from_ref = f"\"{git}\""


@when('the argument --max-commits is provided as "{max_commits}".')
def set_max_commits(context, max_commits):
    context.arguments += f" --max-commits {max_commits} "
