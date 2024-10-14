Feature: A shortened Git commit hash can be provided as an argument to indicate where to start taking the range of commits from till HEAD, instead of a full Git commit hash.


  Scenario Outline: A shortened and full Git commit hash can be used interchangeably.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is clean.
    Given the arguments are reset.
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then the Git history is clean.


    Examples:
      | repository                                  | checkout_commit                          | from_commit_hash                         | from_shortened_commit_hash |
      | https://github.com/haunt98/changeloguru.git | a768f1329b07db76566e0aa3009182a42d2bfe01 | b9fec5dab92558351e69aaa8bc91bc0c76a5ffeb | b9fec5d                    |


  Scenario Outline: A shortened and full Git commit hash can be used interchangeably.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is not clean.
    Given the arguments are reset.
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then the Git history is not clean.


    Examples:
      | repository                             | checkout_commit                          | from_commit_hash                         | from_shortened_commit_hash |
      | https://github.com/asomers/mockall.git | 231bd5ff58ed4f9e99bba74f0239995942f8d29d | e02d8f08f8ab114c79a0e8cf5bd6de860f0f7c2e | e02d8f0                    |


  Scenario Outline: The shortened Git commit hash has no matches, so an error is returned.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then their is a could not find shortened commit hash "<from_shortened_commit_hash>" error.


    Examples:
      | repository                                  | checkout_commit                          | from_shortened_commit_hash |
      | https://github.com/SergioBenitez/Rocket.git | 549c9241c41320fc5af76b53c2ffc3bd8db88f8c | ecfc2c4                    |


  Scenario Outline: The shortened Git commit hash is ambiguous as multiple commit hashes match it, so an error is returned.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then their is a ambiguous shortened commit hash "<from_shortened_commit_hash>" error.


    Examples:
      | repository                                        | checkout_commit                          | from_shortened_commit_hash |
      | https://gitlab.com/DSASanFrancisco/membership_api | bf7dacdba6d030250e0ac26805d80be1feb62012 | ff6                        |
