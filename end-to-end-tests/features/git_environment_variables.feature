Feature: Git environment variables are respected and used instead of using the current working directory.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    Then the Git history is clean.
    Given the GIT_DIR environment variable is set to the cloned repository.
    Then the Git history is clean.


    Examples:
      | repository                                  | checkout_commit                          | commit_hash                              |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | b9fec5dab92558351e69aaa8bc91bc0c76a5ffeb |


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    Then the Git history is not clean.
    Given the GIT_DIR environment variable is set to the cloned repository.
    Then the Git history is not clean.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |
