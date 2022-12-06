Feature: A Git commit hash can be provided as an argument to indicate where to start taking the range of commits from till HEAD to lint.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is clean.


    Examples:
      | repository                                  | checkout_commit                          | from_commit_hash                         |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | b9fec5dab92558351e69aaa8bc91bc0c76a5ffeb |


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
