Feature: When the provided argument is both a Git reference and a shortened Git commit hash, the Git reference is used, as Git itself does.


  # The branch is named after the shortened commit hash of the commit before HEAD, but points at HEAD.
  # So only when the shortened commit hash shadows the branch is there a commit within the range.
  Scenario Outline: The Git reference is used in preference to the shortened Git commit hash.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    Given the branch "<branch>" is created pointing at "<pointing_at>".
    When linting from the "<branch>".
    Then their is a no commits within the provided range error.


    Examples:
      | repository                                  | checkout_commit                          | branch  | pointing_at |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | d828a41 | HEAD        |


  Scenario Outline: A warning is emitted as the provided argument is ambiguous.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    Given the branch "<branch>" is created pointing at "<pointing_at>".
    When the argument --verbose is provided.
    When linting from the "<branch>".
    Then their is an ambiguous reference and commit hash warning for "<branch>".


    Examples:
      | repository                                  | checkout_commit                          | branch  | pointing_at |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | d828a41 | HEAD        |
