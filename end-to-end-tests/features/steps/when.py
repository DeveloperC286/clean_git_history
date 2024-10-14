from behave import when


@when('the argument --from-commit-hash is provided as "{from_commit_hash}".')
def set_from_commit_hash(context, from_commit_hash):
    context.arguments += f" --from-commit-hash {from_commit_hash} "


@when('the argument --from-reference is provided as "{from_reference}".')
def set_from_commit_hash(context, from_reference):
    context.arguments += f" --from-reference {from_reference} "


@when('the --ignore-merge-commits flag is set.')
def set_ignore_merge_commits(context):
    context.arguments += " --ignore-merge-commits "
