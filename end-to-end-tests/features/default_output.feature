Feature: The default output format is automatically detected based on the environment.


  Scenario Outline: When the GITHUB_ACTIONS environment variable is set, the default output format is github.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    And the GITHUB_ACTIONS environment variable is set.
    When linting from the "<commit_hash>".
    Then the GitHub Actions output contains a merge commit error.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |


  Scenario Outline: When the GITHUB_ACTIONS environment variable is not set, the default output format is pretty.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    Then the pretty output contains a merge commit error.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |
