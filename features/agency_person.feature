Feature: Agency Person

  As a user
  I want to login
  So that I can edit my information

  Background:
    Given the following agency roles exist:
      | role  |
      | AA    |
      | CM    |
      | JD    |

    Given the following agencies exist:
      | name    | website     | phone        | email                  | fax          |
      | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

    Given the following agency people exist:
      | agency  | role  | first_name | last_name | email                | password  |  phone       |
      | MetPlus | AA    | John       | Smith     | aa@metplus.org       | qwerty123 | 555-222-3334 |
      | MetPlus | CM    | Jane       | Jones     | jane@metplus.org     | qwerty123 | 555-222-3334 |
      | MetPlus | JD    | Jane       | Developer | jane-dev@metplus.org | qwerty123 | 555-222-3334 |
      | MetPlus | JD    | Bill       | Developer | bill@metplus.org     | qwerty123 | 555-222-3334 |

    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets               |
      | need_case_manager  | jane@metplus.org     | 2016-03-10    | WIP         | john-worker@gmail.com |

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
    And I should see "Work in progress( Jones, Jane )"
    And I should not see "You have no open tasks at this time"

  Scenario: Job Developer without tasks from home page
    Given I am on the home page
    And I login as "bill@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'bill@metplus.org' Home page
    And I should see "Your Open Tasks"
    And I should not see "Job Seeker has no assigned Job Developer"
    And I should not see "Job Seekers Without a Case Manager"
