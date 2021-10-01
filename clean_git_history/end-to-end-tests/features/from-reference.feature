Feature: A Git reference can be provided as an argument to indicate where to start taking the range of commits from till HEAD to lint.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-reference is provided as "<from_reference>".
    Then the Git history is clean.


    Examples:
      | repository                                           | checkout_commit                          | from_reference |
      | https://gitlab.com/eyeo/websites/web.adblockplus.org | 7ba54b39b930e2d55f98a1b08d3ba0cdf6348ed9 | after-sp-1612  |


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-reference is provided as "<from_reference>".
    Then the Git history is not clean.


    Examples:
      | repository                                 | checkout_commit                          | from_reference |
      | https://gitlab.com/gitlab-org/gitlab-shell | 81e580997d07a7a9d3dddbd42cbb39f305c63b8b | v13.18.1       |


  Scenario Outline: You can also provide the long name and partial names not just the short name.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-reference is provided as "<from_full_reference>".
    Then the Git history is clean.
    Given the arguments are reset.
    When the argument --from-reference is provided as "<from_shortened_reference>".
    Then the Git history is clean.


    Examples:
      | repository                                     | checkout_commit                          | from_full_reference | from_shortened_reference |
      | https://github.com/facebookexperimental/Recoil | 09cfcb94d11a3f334bd47f0e24125eee87e4febe | refs/tags/0.4.1     | tags/0.4.1               |


  Scenario Outline: When you provide a reference which does not exist a relevant error message is returned.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-reference is provided as "<from_reference>".
    Then their is a could not find reference "<from_reference>" error.


    Examples:
      | repository                           | checkout_commit                          | from_reference |
      | https://gitlab.com/klutchell/unbound | 521d84f6d2cd150b9831f89c17a9a1d92e626dd4 | 3.12.7         |
