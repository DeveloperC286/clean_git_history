Feature: The pretty output format only emits colour when the environment supports it.


  Scenario Outline: When standard output is not a terminal, the pretty output is not coloured.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    And the argument --output is provided as "pretty".
    Then the pretty output is not coloured.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |


  Scenario Outline: When the CLICOLOR_FORCE environment variable is set, the pretty output is coloured.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    And the CLICOLOR_FORCE environment variable is set.
    When linting from the "<commit_hash>".
    And the argument --output is provided as "pretty".
    Then the pretty output is coloured.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |


  Scenario Outline: When the NO_COLOR environment variable is set, the pretty output is not coloured.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    And the NO_COLOR environment variable is set.
    And the CLICOLOR_FORCE environment variable is set.
    When linting from the "<commit_hash>".
    And the argument --output is provided as "pretty".
    Then the pretty output is not coloured.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |
