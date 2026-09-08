Feature: Pretty output format only emits colour when the output is a terminal.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    And the argument --output is provided as "pretty".
    Then the pretty output contains a merge commit error.
    And the pretty output contains no ANSI escape codes.


    Examples:
      | repository                             | checkout_commit                          | commit_hash                              |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e |
