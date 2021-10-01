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
      | repository                                            | checkout_commit                          | from_commit_hash                         |
      | https://github.com/HashLips/generative-art-opensource | 2d74294cc7d187262e9069c1f1189424642954e5 | 853a55fab4e139749e7b37eadad0d0e77b2c8605 |