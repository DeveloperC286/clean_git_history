Feature: If the flag is enabled then any Git merge commits are ignored, otherwise a merge commit's presence will cause linting to fail.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is not clean.
    Given the arguments are reset.
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    And the --ignore-merge-commits flag is set.
    Then the Git history is clean.


    Examples:
      | repository                             | checkout_commit                          | from_commit_hash                         |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |
