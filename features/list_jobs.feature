Feature: Search Jobs

As a PETS user
I want to see the list of available jobs

Background: set up the jobs environment

  Given the following agencies exist:
    | name    | website     | phone        | email                  | fax          |
    | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com   | corp@ymail.com   | 12-3456789 | active |

  Given the following company roles exist:
    | role  |
    | CA    |
    | CC    |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com | qwerty123 | 555-222-3334 |
    | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com   | qwerty123 | 555-222-3334 |

  Given the following job skills exist:
    | name       | description                            |
    | Skill1     | Topo planning for construction         |
    | Skill2     | Promote tourism for region or location |
    | Skill3     | Long haul driver with Class C license  |

@javascript
Scenario: Tailor heading for the number of jobs found
  # Display when no jobs
  Given I am on the home page
  And I click the "Jobs" link
  And I wait 1 second
  Then I should see "0 Jobs Found."
  And I should not see "Click on any column title to sort."
    # Display when 1 job
  Given the following jobs exist:
    | title | description | company      | creator          | skills         | city  |
    | Job1  | About job1. | Widgets Inc. | jane@ymail.com   | Skill1, Skill2 | city1 |
  Given I am on the home page
  And I click the "Jobs" link
  And I wait 1 second
  Then I should see "1 Job Found."
  And I should not see "Click on any column title to sort."
    # Display when 2 or more jobs
  Given the following jobs exist:
    | title | description | company      | creator          | skills         | city  |
    | Job2  | About job2. | Widgets Inc. | carter@ymail.com | Skill3         | city2 |
  Given I am on the home page
  And I click the "Jobs" link
  And I wait 1 second
  Then I should see "2 Jobs Found."
  And I should see "Click on any column title to sort."
  