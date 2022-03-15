Feature: A Git commit hash can be provided as an argument to indicate where to start taking the range of commits from till HEAD to lint.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is clean.


    Examples:
      | repository                                   | checkout_commit                          | from_commit_hash                         |
      | https://github.com/TheAlgorithms/C-Plus-Plus | f7d656cb17c8b355fa6a51e45a070cd6995ed110 | 47c84137eec683790faa494ac0068d7c9f88f8ff |


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is not clean.


    Examples:
      | repository                                            | checkout_commit                          | from_commit_hash                         |
      | https://github.com/HashLips/generative-art-opensource | 2d74294cc7d187262e9069c1f1189424642954e5 | 853a55fab4e139749e7b37eadad0d0e77b2c8605 |


  Scenario Outline: When you provide an invalid commit hash a relevant error message is returned.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then their is a could not find commit hash "<from_commit_hash>" error.


    Examples:
      | repository                                  | checkout_commit                          | from_commit_hash                         |
      | https://github.com/SergioBenitez/Rocket.git | 549c9241c41320fc5af76b53c2ffc3bd8db88f8c | ecfc2c474575c6cdbc6d273c94c13181bd1dbaa6 |
