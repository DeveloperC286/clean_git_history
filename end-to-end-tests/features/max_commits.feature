Feature: The maximum number of commits allowed, if exceeded will cause linting to fail.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    Then the Git history is clean.
    Given the arguments are reset.
    When linting from the "<commit_hash>".
    And the argument --max-commits is provided as "<max_commits>".
    Then the Git history is not clean.


    Examples:
      | repository                                                | checkout_commit                          | commit_hash                              | max_commits |
      | https://github.com/DeveloperC286/zsh-simple-abbreviations | 2f6658245d0674d614687d62a53d9bae7aa9ac42 | a045cc7fff60f055908a16ed697a395256bc6c7d | 1           |


  Scenario Outline: When the maximum number of commits is provided as 0 an invalid value error is returned.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<commit_hash>".
    And the argument --max-commits is provided as "0".
    Then their is an invalid max commits value "0" error.


    Examples:
      | repository                                                | checkout_commit                          | commit_hash                              |
      | https://github.com/DeveloperC286/zsh-simple-abbreviations | 2f6658245d0674d614687d62a53d9bae7aa9ac42 | a045cc7fff60f055908a16ed697a395256bc6c7d |
