Feature: A Git reference can be provided as an argument to indicate where to start taking the range of commits from till HEAD to lint.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<reference>".
    Then the Git history is clean.


    Examples:
      | repository                              | checkout_commit                          | reference |
      | https://github.com/mbarkhau/bumpver.git | a3f034ac866ea919343c80d7157ae0eef2133c39 | 2023.1124 |


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<reference>".
    Then the Git history is not clean.


    Examples:
      | repository                                 | checkout_commit                          | reference |
      | https://gitlab.com/gitlab-org/gitlab-shell | 81e580997d07a7a9d3dddbd42cbb39f305c63b8b | v13.18.1  |


  Scenario Outline: You can also provide the long name and partial names not just the short name.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<full_reference>".
    Then the Git history is clean.
    Given the arguments are reset.
    When linting from the "<partial_reference>".
    Then the Git history is clean.
    Given the arguments are reset.
    When linting from the "<short_reference>".
    Then the Git history is clean.


    Examples:
      | repository                            | checkout_commit                          | full_reference   | partial_reference | short_reference |
      | https://github.com/la10736/rstest.git | 49409736065b43c01b3dcfdf2dc068c349c488a0 | refs/tags/0.16.0 | tags/0.16.0       | 0.16.0          |


  Scenario Outline: When you provide an invalid reference a relevant error message is returned.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When linting from the "<reference>".
    Then their is a could not find reference "<reference>" error.


    Examples:
      | repository                           | checkout_commit                          | reference |
      | https://gitlab.com/klutchell/unbound | 521d84f6d2cd150b9831f89c17a9a1d92e626dd4 | 3.12.7    |
