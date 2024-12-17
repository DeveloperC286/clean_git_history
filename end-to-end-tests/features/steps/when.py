from behave import when


@when('linting from the "{git}".')
def set_linting_from_the(context, git):
    context.from_ref = f" \"{git}\""


@when('the --ignore-merge-commits flag is set.')
def set_ignore_merge_commits(context):
    context.arguments += " --ignore-merge-commits "


@when('the argument --max-commits is provided as "{max_commits}".')
def set_max_commits(context, max_commits):
    context.arguments += f" --max-commits {max_commits} "
