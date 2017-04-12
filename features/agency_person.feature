Feature: Agency Person

  As an user
  I want to login to PETS
  And manage my work from my home page

  Background: seed data added to database and log in as agency admin

    Given the default settings are present

    Given the following agency people exist:
      | agency  | role      | first_name | last_name | phone        | email                | password  |
      | MetPlus | AA,CM,JD  | John       | Smith     | 555-111-2222 | aa@metplus.org       | qwerty123 |
      | MetPlus | CM        | Jane       | Jones     | 555-111-2222 | jane@metplus.org     | qwerty123 |
      | MetPlus | JD        | Jane       | Developer | 555-111-2222 | jane-dev@metplus.org | qwerty123 |
      | MetPlus | JD        | Bill       | Developer | 555-111-2222 | bill@metplus.org     | qwerty123 |
      | MetPlus | JD,CM     | Mark       | Smith     | 555-111-2222 | mark@metplus.org     | qwerty123 |


    Given the following jobseekers exist:
      | first_name| last_name| email                     | phone       | password | year_of_birth |job_seeker_status |
      | John      | Seeker   | john.seeker@gmail.com     | 345-890-7890| password | 1990          |Unemployed Seeking |
      | John      | Worker   | john.worker@gmail.com     | 345-890-7890| password | 1990          |Employed Looking   |
      | Wanda     | Worker   | wanda.worker@gmail.com    | 345-890-7890| password | 1990          |Employed Looking   |
      | Tom       | Seeker   | tom.seeker@gmail.com      | 345-890-7890| password | 1990          |Employed Looking   |
      | Mary      | Jones    | mary.jones@gmail.com      | 345-890-7890| password | 1990          |Employed Looking   |


    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets               |
      | need_job_developer | MetPlus,JD           | 2016-03-10    | NEW         | john-seeker@gmail.com |
      | need_case_manager  | MetPlus,CM           | 2016-03-10    | NEW         | john-seeker@gmail.com |
      | need_job_developer | jane-dev@metplus.org | 2016-03-10    | ASSIGNED    | john-worker@gmail.com |
      | need_case_manager  | jane@metplus.org     | 2016-03-10    | WIP         | john-worker@gmail.com |
      | need_case_manager  | aa@metplus.org       | 2016-03-10    | ASSIGNED    | john-seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | WIP         | john-seeker@gmail.com |
      | need_job_developer | aa@metplus.org       | 2016-03-10    | DONE        | john-worker@gmail.com |

Given the following agency relations exist:
  	| job_seeker      | agency_person    | role |
  	| tom.seeker@gmail.com | mark@metplus.org   | JD   |
  	| mary.jones@gmail.com | mark@metplus.org   | CM   |

@javascript
Scenario: Case Manager actions
  # login and edit profile
  Given I am on the home page
  And I login as "jane@metplus.org" with password "qwerty123"
  And I wait 1 second
  And I should be on the Agency Person 'jane@metplus.org' Home page
  And I should see "Your Job Seekers (as CM)"
  And I should not see "Job Seekers without a JD"
  And I click the "Hello, Jane" link
  And I click the "My Profile" link
  Then I click the "Edit" link
  And I should see "Jane"
  And I fill in "First Name" with "Janey"

  # change email
  When I fill in "Email" with "janey@metplus.org"
  And I click "Update Your Profile" button
  Then I should be on the Agency Person 'jane@metplus.org' Home page
  And I should see "Please check your inbox to confirm your email address"
  And "janey@metplus.org" should receive an email with subject "Confirmation instructions"
  When I open the email
  And I follow "Confirm my account" in the email
  Then I should see "Your email address has been successfully confirmed."
  When I click the "Hello, Janey" link
  And I click the "My Profile" link
  And I click the "Edit" link
  Then I should see "janey@metplus.org" in the email field

  # See tasks on home page
  Given I am on the Agency Person 'janey@metplus.org' Home page
  And I should see "Your Open Tasks"
  And I should see "Job Seeker has no assigned Case Manager"
  And I should see "Work in progress( Jones, Janey )"
  And I should not see "You have no open tasks at this time"
  Then I press the done button of the task 4
  And I wait 1 second
  And I should see notification "Work on the task is done"

  # Assigns self to job seeker
  And I click the "Job Seekers without a CM" link
  And I wait 1 second
  And I click the "Worker, Wanda" link
  And I should not see "Janey Jones"
  And I should see "Assign Myself"
  And I click the "Assign Myself" button
  Then I should see "Janey Jones"
  And I should not see "Assign Myself"

  # can edit her job seeker's profile
  And I reload the page
  Then I click "Edit Job Seeker" button
  And I should see "Edit JobSeeker Registration"
  And I should not see "Password"
  And I should not see "Password Confirmation"
  And I should not see "Year of Birth"
  Then I fill in "First Name" with "Samantha"
  Then I click "Update Job seeker" button
  And I should see "Jobseeker was updated successfully."
  And I should not see "Mary"
  And I should see "Samantha"

  # cannot edit other job seekers' profile
  Given I am on the Agency Person 'janey@metplus.org' Home page
  And I wait 1 second
  And I click the "Job Seekers without a CM" link
  And I wait 1 second
  Then I click the first "Seeker, John" link
  And I should not see "Edit Job Seeker"

@javascript
Scenario: Job Developer actions
  # JD without tasks
  Given I am on the home page
  And I login as "bill@metplus.org" with password "qwerty123"
  And I should be on the Agency Person 'bill@metplus.org' Home page
  And I should see "Your Job Seekers (as JD)"
  And I should see "There are no job seekers assigned to you yet."

  # JD with tasks
  And I click the "Hello, Bill" link
  Then I logout
  And I login as "jane-dev@metplus.org" with password "qwerty123"
  And I should be on the Agency Person 'jane-dev@metplus.org' Home page
  And I should see "Your Open Tasks"
  And I should see "Job Seeker has no assigned Job Developer"
  And I should not see "Job Seeker has no assigned Case Manager"
  And the task 3 status is "Assigned"
  Then I press the wip button of the task 3
  And I should see notification "Work on the task started"
  And the task 3 status is "Work in progress"
  Then I press the done button of the task 3
  And I should see notification "Work on the task is done"

  # Assigns self to job seeker
  And I click the "Job Seekers without a JD" link
  And I wait 1 second
  Then I click the "Worker, John" link
  And I should see "Assign Myself"
  And I click the "Assign Myself" button
  Then I should see "Jane Developer"
  And I should not see "Assign Myself"

@javascript
Scenario: Agency Admin actions
  # see all tasks
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  And I should be on the Agency Person 'aa@metplus.org' Home page
  And I should see "Unassigned Agency Tasks"
  And I should see "Your Open Tasks"
  And I should see "All Agency Open Tasks"
  And I should see "Closed Tasks"
  And the tasks 5,6 are present
  And the tasks 1,2,3,4,7 are hidden
  And I click the "Unassigned Agency Tasks" link
  And the tasks 1,2 are present
  And the tasks 3,4,7 are hidden
  And I click the "All Agency Open Tasks" link
  And the tasks 3,4,5,6 are present
  And the tasks 1,2,7 are hidden
  And I click the "Closed Tasks" link
  And the task 7 is present
  And the tasks 1,2,3,4 are hidden

  # assign task
  And I click the "Unassigned Agency Tasks" link
  Then I press the assign button of the task 2
  And I should see "Select the user to assign the task to:"
  And I select2 "Jones, Jane" from "task_assign_select"
  Then I press "Assign"
  And I should see notification "Task assigned"
  And I wait 2 seconds
  And the task 2 is not present
  And I click the "All Agency Open Tasks" link
  And the task 2 is present

@javascript
Scenario: Job seekers assigned to person as Job developer and case manager
  Given I am on the home page
  And I login as "mark@metplus.org" with password "qwerty123"
  And I should be on the Agency Person 'mark@metplus.org' Home page
  And I should see "Your Job Seekers (as JD)"
  And I should see "Seeker, Tom"
  And I click the "Your Job Seekers (as CM)" link
  And I should see "Jones, Mary"
