Feature: The from arguments conflict with one another and can not be provided at the same time.


  Scenario Outline: You can not provide both a reference and a commit hash.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-reference is provided as "<from_reference>".
    And the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then their is a conflicting from arguments error.


    Examples:
      | repository                         | checkout_commit                          | from_commit_hash                         | from_reference |
      | https://github.com/yargs/yargs.git | 0f810245494ccf13a35b7786d021b30fc95ecad5 | 028b50d5ced3b41a8dccf74107dbfc7065052a5d | v15.4.0        |
