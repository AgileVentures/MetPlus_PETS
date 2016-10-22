Feature: Have a task system in the site

  As an user
  I want to login to PETS
  And manage my tasks

  Background: seed data added to database and log in as agency admim

    Given the default settings are present

    Given the following agency people exist:
      | agency  | role      | first_name | last_name | email                | password  |
      | MetPlus | AA,CM,JD  | John       | Smith     | aa@metplus.org       | qwerty123 |
      | MetPlus | CM        | Jane       | Jones     | jane@metplus.org     | qwerty123 |
      | MetPlus | JD        | Jane       | Developer | jane-dev@metplus.org | qwerty123 |

    Given the following jobseeker exist:
      | first_name| last_name| email                     | phone       |password  |password_confirmation| year_of_birth |job_seeker_status |
      | John      | Seeker   | john.seeker@gmail.com     | 345-890-7890| password |password             | 1990          |Unemployed Seeking |
      | John      | Worker   | john.worker@gmail.com     | 345-890-7890| password |password             | 1990          |Employed Looking   |

    Given the following companies exist:
      | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | pending_registration |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email            | password  | phone        |
      | Widgets Inc. | CA    | Steve      | Jobs      | ca@widgets.com   | qwerty123 | 555-222-3334 |
      | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |


    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets               |
      | need_job_developer | MetPlus,JD           | 2016-03-10    | NEW         | john.seeker@gmail.com |
      | need_case_manager  | MetPlus,CM           | 2016-03-10    | NEW         | john.seeker@gmail.com |
      | need_job_developer | jane-dev@metplus.org | 2016-03-10    | ASSIGNED    | john.worker@gmail.com |
      | need_case_manager  | jane@metplus.org     | 2016-03-10    | WIP         | john.worker@gmail.com |
      | need_case_manager  | aa@metplus.org       | 2016-03-10    | ASSIGNED    | john.seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | WIP         | john.seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | DONE        | john.worker@gmail.com |
      | company_registration | MetPlus,AA         | 2016-03-10    | NEW         | Widgets Inc.          |
      | job_application    | Widgets Inc.,CA      | 2016-03-10    | NEW         | john-seeker@gmail.com |
      | job_application    | ca@widgets.com       | 2016-03-10    | NEW         | john-seeker@gmail.com |


  @selenium
  Scenario: Agency admin assign task to other JD and task is removed from his view
    Given I am on the home page
    And I login as "aa@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    Then I go to the tasks page
    And The tasks 1,2,5,6,7,8 are present
    And I should see "Job Seeker has no assigned Job Developer"
    And I should see "Job Seeker has no assigned Job Developer" after "Tasks completed by you"
    Then I press the assign button of the task 2
    And I should see "Select the user to assign the task to:"
    And I select2 "Jones, Jane" from "task_assign_select"
    Then I press "Assign"
    And I wait 1 second
    And I should see notification "Task assigned"
    And The task 2 is not present

  @selenium
  Scenario: Agency admin can see company registration
    Given I am on the home page
    And I login as "aa@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    Then I go to the tasks page
    And I wait 2 seconds
    And I should see "Widgets Inc."
    And I click the "Widgets Inc." link
    And I wait 1 second
    And I should see "Company Registration Information"

  @selenium
  Scenario: company admin can view and assign tasks
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    Then I should see "Signed in successfully."
    And I wait 1 second
    And The tasks 9,10 are present
    Then I press the assign button of the task 9
    And I should see "Select the user to assign the task to:"
    And I select2 "Smith, Jane" from "task_assign_select"
    Then I press "Assign"
    And I wait 1 second
    And I should see notification "Task assigned"
    And The task 9 is not present
