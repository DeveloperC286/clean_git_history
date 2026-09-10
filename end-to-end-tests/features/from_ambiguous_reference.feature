Feature: When the provided argument matches more than one thing, the same one Git itself resolves to is used.


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


  Scenario Outline: A warning is emitted as the provided argument is both a Git reference and a shortened Git commit hash.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    Given the branch "<branch>" is created pointing at "<pointing_at>".
    When the argument --verbose is provided.
    When linting from the "<branch>".
    Then their is an ambiguous reference and commit hash warning for "<branch>".


    Examples:
      | repository                                  | checkout_commit                          | branch  | pointing_at |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | d828a41 | HEAD        |


  # Unlike a shortened commit hash, Git uses a full commit hash in preference to a reference of the same name.
  # The branch is named after the full commit hash of the commit before HEAD, but points at HEAD.
  # So only when the branch shadows the full commit hash is there no commit within the range.
  Scenario Outline: The full Git commit hash is used in preference to the Git reference.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    Given the branch "<branch>" is created pointing at "<pointing_at>".
    When linting from the "<branch>".
    Then the Git history is clean.


    Examples:
      | repository                                  | checkout_commit                          | branch                                   | pointing_at |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | d828a41601b950843639535489c57b855c9852dd | HEAD        |


  Scenario Outline: A warning is emitted as the provided argument is both a full Git commit hash and a Git reference.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    Given the branch "<branch>" is created pointing at "<pointing_at>".
    When the argument --verbose is provided.
    When linting from the "<branch>".
    Then their is an ambiguous full commit hash and reference warning for "<branch>".


    Examples:
      | repository                                  | checkout_commit                          | branch                                   | pointing_at |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | d828a41601b950843639535489c57b855c9852dd | HEAD        |


  # Git matches a tag before a branch, the tag points at the commit before HEAD and the branch points at HEAD.
  # So only when the branch is matched before the tag is there no commit within the range.
  Scenario Outline: The Git tag is used in preference to the Git branch of the same name.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    Given the tag "<name>" is created pointing at "<tag_pointing_at>".
    Given the branch "<name>" is created pointing at "<branch_pointing_at>".
    When linting from the "<name>".
    Then the Git history is clean.


    Examples:
      | repository                                  | checkout_commit                          | name      | tag_pointing_at | branch_pointing_at |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | ambiguous | HEAD~1          | HEAD               |


  Scenario Outline: A warning is emitted as the provided argument matches multiple Git references.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    Given the tag "<name>" is created pointing at "<tag_pointing_at>".
    Given the branch "<name>" is created pointing at "<branch_pointing_at>".
    When the argument --verbose is provided.
    When linting from the "<name>".
    Then their is an ambiguous references warning for "<name>".


    Examples:
      | repository                                  | checkout_commit                          | name      | tag_pointing_at | branch_pointing_at |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | ambiguous | HEAD~1          | HEAD               |
