Feature: Git environment variables are respected and used instead of using the current working directory.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is clean.
    Given the GIT_DIR environment variable is set to the cloned repository.
    Then the Git history is clean.


    Examples:
      | repository                                  | checkout_commit                          | from_commit_hash                         |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | b9fec5dab92558351e69aaa8bc91bc0c76a5ffeb |


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is not clean.
    Given the GIT_DIR environment variable is set to the cloned repository.
    Then the Git history is not clean.


    Examples:
      | repository                                            | checkout_commit                          | from_commit_hash                         |
      | https://github.com/HashLips/generative-art-opensource | 2d74294cc7d187262e9069c1f1189424642954e5 | 853a55fab4e139749e7b37eadad0d0e77b2c8605 |
