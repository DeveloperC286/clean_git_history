Feature: Pretty output format prints human readable linting errors.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    And the argument --output is provided as "pretty".
    Then the output is in the pretty format.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |


  Scenario Outline: When the GITHUB_ACTIONS environment variable is set, the pretty output format is still used.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    And the GITHUB_ACTIONS environment variable is set.
    When linting from the "<commit_hash>".
    And the argument --output is provided as "pretty".
    Then the output is in the pretty format.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |
