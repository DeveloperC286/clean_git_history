Feature: Shortened commit hashes are supported and can be supplied in place of full commit hashes.


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is clean.
    Given the arguments are reset.
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then the Git history is clean.


    Examples:
      | repository                                   | checkout_commit                          | from_commit_hash                         | from_shortened_commit_hash |
      | https://github.com/TheAlgorithms/C-Plus-Plus | f7d656cb17c8b355fa6a51e45a070cd6995ed110 | 47c84137eec683790faa494ac0068d7c9f88f8ff | 47c8413                    |


  Scenario Outline:
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_commit_hash>".
    Then the Git history is not clean.
    Given the arguments are reset.
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then the Git history is not clean.


    Examples:
      | repository                                            | checkout_commit                          | from_commit_hash                         | from_shortened_commit_hash |
      | https://github.com/HashLips/generative-art-opensource | 2d74294cc7d187262e9069c1f1189424642954e5 | 853a55fab4e139749e7b37eadad0d0e77b2c8605 | 853a55f                    |


  Scenario Outline: The short commit hash matches no commit hashes. So an error is printed and it exits unsuccessfully.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then their is a could not find shortened commit hash "<from_shortened_commit_hash>" error.


    Examples:
      | repository                                  | checkout_commit                          | from_shortened_commit_hash |
      | https://github.com/SergioBenitez/Rocket.git | 549c9241c41320fc5af76b53c2ffc3bd8db88f8c | ecfc2c4                    |


  Scenario Outline: The short commit hash is ambiguous, multiple commit hashes match it. So an error is printed and it exits unsuccessfully.
    Given the repository "<repository>" is cloned and checked out at the commit "<checkout_commit>".
    When the argument --from-commit-hash is provided as "<from_shortened_commit_hash>".
    Then their is a ambiguous shortened commit hash "<from_shortened_commit_hash>" error.


    Examples:
      | repository                                        | checkout_commit                          | from_shortened_commit_hash |
      | https://gitlab.com/DSASanFrancisco/membership_api | bf7dacdba6d030250e0ac26805d80be1feb62012 | ff6                        |