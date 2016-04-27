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
      | John      | Seeker   | john-seeker@gmail.com     | 345-890-7890| password |password             | 1990          |Unemployedlooking |
      | John      | Worker   | john-worker@gmail.com     | 345-890-7890| password |password             | 1990          |Employedlooking   |

    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets               |
      | need_job_developer | MetPlus,JD           | 2016-03-10    | NEW         | john-seeker@gmail.com |
      | need_case_manager  | MetPlus,CM           | 2016-03-10    | NEW         | john-seeker@gmail.com |
      | need_job_developer | jane-dev@metplus.org | 2016-03-10    | ASSIGNED    | john-worker@gmail.com |
      | need_case_manager  | jane@metplus.org     | 2016-03-10    | WIP         | john-worker@gmail.com |
      | need_case_manager  | aa@metplus.org       | 2016-03-10    | ASSIGNED    | john-seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | WIP         | john-seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | DONE        | john-worker@gmail.com |

  @selenium
  Scenario: Job Developer assigns tasks and complete it
    Given I am on the home page
    And I login as "jane-dev@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    Then I go to the tasks page
    And I wait 1 second
    And I should see "Job Seeker has no assigned Job Developer"
    And I should not see "Job Seeker has no assigned Job Developer" after "Tasks completed by you"
    And The task 1 status is "New"
    Then I press the assign button of the task 1
    And I should see "Select the user to assign the task to:"
    And I select2 "Developer, Jane" from "task_assign_select"
    Then I press "Assign"
    And I wait 1 second
    And I should see notification "Task assigned"
    And The task 1 status is "Assigned"
    Then I press the wip button of the task 1
    And I wait 1 second
    And I should see notification "Work on the task started"
    And The task 1 status is "Work in progress"
    And I wait 2 second
    Then I press the done button of the task 1
    And I wait 1 second
    And I should see notification "Work on the task is done"

  @selenium
  Scenario: Agency admin assign task to other JD and task is removed from his view
    Given I am on the home page
    And I login as "aa@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    Then I go to the tasks page
    And The tasks 1,2,5,6,7 are present
    And I should see "Job Seeker has no assigned Job Developer"
    And I should not see "Job Seeker has no assigned Job Developer" after "Tasks completed by you"
    Then I press the assign button of the task 2
    And I should see "Select the user to assign the task to:"
    And I select2 "Jones, Jane" from "task_assign_select"
    Then I press "Assign"
    And I wait 1 second
    And I should see notification "Task assigned"
    And The task 2 is not present

  @selenium
  Scenario: Case Manager open and closes assign modal
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    Then I go to the tasks page
    And The tasks 2,4 are present
    And I should not see "Job Seeker has no assigned Job Developer"
    And I should see "Job Seeker has no assigned Case Manager"
    And I should not see "Job Seeker has no assigned Case Manager" after "Tasks completed by you"
    Then I press the assign button of the task 2
    And I should see "Select the user to assign the task to:"
    Then I press "Cancel"
    And I wait 1 seconds
    And I should not see notification "Task assigned"
    And The task 2 status is "New"
