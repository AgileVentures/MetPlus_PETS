Feature: Have a task system in the site

  As an user
  I want to login to PETS
  And manage my tasks

  Background: seed data added to database and log in as agency admim

    Given the default settings are present

    Given the following agency people exist:
      | agency  | role      | first_name | last_name | phone        | email                | password  |
      | MetPlus | AA,CM,JD  | John       | Smith     | 555-111-2222 | aa@metplus.org       | qwerty123 |
      | MetPlus | CM        | Jane       | Jones     | 555-111-2222 | jane@metplus.org     | qwerty123 |
      | MetPlus | JD        | Jane       | Developer | 555-111-2222 | jane-dev@metplus.org | qwerty123 |
      | MetPlus | JD        | Bill       | Developer | 555-111-2222 | bill@metplus.org | qwerty123 |

    Given the following jobseeker exist:
      | first_name| last_name| email                     | phone       |password  |password_confirmation| year_of_birth |job_seeker_status |
      | John      | Seeker   | john-seeker@gmail.com     | 345-890-7890| password |password             | 1990          |Unemployed Seeking |
      | John      | Worker   | john-worker@gmail.com     | 345-890-7890| password |password             | 1990          |Employed Looking   |


    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets               |
      | need_job_developer | MetPlus,JD           | 2016-03-10    | NEW         | john-seeker@gmail.com |
      | need_case_manager  | MetPlus,CM           | 2016-03-10    | NEW         | john-seeker@gmail.com |
      | need_job_developer | jane-dev@metplus.org | 2016-03-10    | ASSIGNED    | john-worker@gmail.com |
      | need_case_manager  | jane@metplus.org     | 2016-03-10    | WIP         | john-worker@gmail.com |
      | need_case_manager  | aa@metplus.org       | 2016-03-10    | ASSIGNED    | john-seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | WIP         | john-seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | DONE        | john-worker@gmail.com |

  Scenario: Case Manager login and edit from home page
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'jane@metplus.org' Home page
    And I should see "Your Job Seekers (Case Manager)"
    And I should not see "Job Seekers Without a Job Developer"
    Then I press "edit-profile"
    And I should see "Jane"
    And I fill in "First Name" with "Samantha"
    Then I click "Update Agency person" button
    And I should see "Your profile was updated successfully."
    And I should not see "Jane"
    And I should see "Samantha"

  Scenario: Case Manager with tasks on home page
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'jane@metplus.org' Home page
    And I should see "Your Open Tasks"
    And I should see "Job Seeker has no assigned Case Manager"
    And I should see "Work In Progress"
    And I should not see "You have no open tasks at this time"

  Scenario: Job Developer without tasks from home page
    Given I am on the home page
    And I login as "bill@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'bill@metplus.org' Home page
    And I should see "Your Open Tasks"
    And I should not see "Job Seeker has no assigned Job Developer"
    And I should see "Your Job Seekers"
    And I should see "There are no job seekers assigned to you yet."
    And I should not see "Job Seekers Without a Case Manager"
