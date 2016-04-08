Feature: Have a task system in the site

  As an user
  I want to login to PETS
  And manage my tasks

  Background: seed data added to database and log in as agency admim

    Given the following agency roles exist:
      | role  |
      | AA    |
      | CM    |
      | JD    |

    Given the following agencies exist:
      | name    | website     | phone        | email                  | fax          |
      | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

    Given the following agency people exist:
      | agency  | role      | first_name | last_name | email                | password  |
      | MetPlus | AA,CM,JD  | John       | Smith     | aa@metplus.org       | qwerty123 |
      | MetPlus | CM        | Jane       | Jones     | jane@metplus.org     | qwerty123 |
      | MetPlus | JD        | Jane       | Developer | jane-dev@metplus.org | qwerty123 |
    Given the following jobseekerstatus values exist:
      | value                | description |
      | Unemployedlooking    | A jobseeker without any work and looking for a job|
      | Employedlooking      | A jobseeker with a job and looking for a job      |
      | Employednotlooking   | A jobseeker with a job and not looking for a job for now.|

    Given the following jobseeker exist:
      | first_name| last_name| email                     | phone       |password  |password_confirmation| year_of_birth |job_seeker_status |
      | vijaya    | karumudi | vijaya.karumudi@gmail.com | 345-890-7890| password   |password               | 1990       |Unemployedlooking |

    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets                   |
      | need_job_developer | MetPlus,JD           | 2016-03-10    | NEW         | vijaya.karumudi@gmail.com |
      | need_case_manager  | MetPlus,CM           | 2016-03-10    | NEW         | vijaya.karumudi@gmail.com |
      | need_job_developer | jane-dev@metplus.org | 2016-03-10    | ASSIGNED    | vijaya.karumudi@gmail.com |
      | need_case_manager  | jane@metplus.org     | 2016-03-10    | WIP         | vijaya.karumudi@gmail.com |
      | need_case_manager  | aa@metplus.org       | 2016-03-10    | ASSIGNED    | vijaya.karumudi@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | WIP         | vijaya.karumudi@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | DONE        | vijaya.karumudi@gmail.com |

  @javascript
  Scenario: Assign myself a task as JD
    Given I am on the home page
    And I login as "jane-dev@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    Then I go to the tasks page
    And I should see "Job Seeker has no assigned Job Developer"
    Then I press the assign button of the task 1
    And I should see "Select the user to assign the task to:"
    And I select "Smith, John" in select list "task_assign_select"