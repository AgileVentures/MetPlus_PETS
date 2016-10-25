Feature: Company Person

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
      | agency  | role  | first_name | last_name | email            | password  |
      | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
      | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 |

    Given the following company roles exist:
      | role  |
      | CA    |
      | CC    |

    Given the following companies exist:
      | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | active |
      | MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | corp@feature.com | 12-3456788 | active |

    Given the following company addresses exist:
      | company       | street           | city    | zipcode | state      |
      | Widgets Inc.  | 12 Main Street   | Detroit | 02034   | Michigan   |
      | Widgets Inc.  | 14 Main Street   | Detroit | 02034   | Michigan   |
      | Feature Inc.  | 100 River Valley | Utah    | 12334   | New Jersey |
      | Feature Inc.  | 111 River Valley | Utah    | 12334   | New Jersey |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email            | password  | phone        |
      | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
      | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |
      | Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |

    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets               |
      | job_application    | jane@widgets.com     | 2016-03-10    | ASSIGNED    | john-seeker@gmail.com |


  Scenario: company admin edits company info
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I should see "Edit Company Info"
    Then I click the "Edit Company Info" link
    Then I should see "Edit Company"
    And I fill in "Website" with "www.widgets-inc.com"
    And I click the "Submit" button
    Then I should see "company was successfully updated."

  @javascript
  Scenario: company admin can edit and delete company person
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I wait 1 second
    Then I click the "Smith, Jane" link
    And I should see button "Edit Person"
    And I should see button "Delete Person"

  @javascript
  Scenario: company admin can edit but not delete himself
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I wait 1 second
    Then I click the "Smith, Jane" link
    And I should see button "Edit Person"
    And I should see button "Delete Person"

  @javascript
  Scenario: agency admin can edit and delete company person
    Given I am on the home page
    And I login as "aa@metplus.org" with password "qwerty123"
    And I wait 1 second
    And I click the "Admin" link
    And I click the "Agency and Partner Companies" link
    Then I click the "Widgets Inc." link
    Then I click the "Smith, Jane" link
    And I should see button "Edit Person"
    And I should see button "Delete Person"

  Scenario: company contact cannot edit company nor invite person_type
    Given I am on the home page
    And I login as "jane@widgets.com" with password "qwerty123"
    And I should not see "Edit Company Info"
    And I should not see "Invite Colleague"

  Scenario: company admin login and edit profile from home page
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I should be on the Company Person 'ca@widgets.com' Home page
    Then I press "edit-profile"
    And I should see "John"
    And I fill in "First Name" with "Tom"
    Then I click "Update Company person" button
    And I should see "Your profile was updated successfully."
    And I should not see "John"
    And I should see "Tom"

  Scenario: company contact login and edit profile from home page
    Given I am on the home page
    And I login as "jane@widgets.com" with password "qwerty123"
    And I should be on the Company Person 'jane@widgets.com' Home page
    Then I press "edit-profile"
    And I should see "Jane"
    And I fill in "First Name" with "Mary"
    Then I click "Update Company person" button
    And I should see "Your profile was updated successfully."
    And I should not see "Jane"
    And I should see "Mary"

  Scenario: company contact login and edit profile from name
    Given I am on the home page
    And I login as "jane@widgets.com" with password "qwerty123"
    And I should be on the Company Person 'jane@widgets.com' Home page
    Then I press "Jane"
    And I am on the 'jane@widgets.com' edit profile page
    And I should see "Jane"
    And I fill in "First Name" with "Mary"
    Then I click "Update Company person" button
    And I should see "Your profile was updated successfully."
    And I should not see "Jane"
    And I should see "Mary"

  Scenario: company admin login and edit profile from name
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I should be on the Company Person 'ca@widgets.com' Home page
    Then I press "John"
    And I am on the 'ca@widgets.com' edit profile page
    And I should see "John"
    And I fill in "First Name" with "Tom"
    Then I click "Update Company person" button
    And I should see "Your profile was updated successfully."
    And I should not see "John"
    And I should see "Tom"

  Scenario: company admin can update address
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    Then I press "edit-profile"
    And I do not have an address
    And I should see selections of "Widgets Inc." addresses
    And I should not see selections of "Feature Inc." addresses
    And I select "12 Main Street Detroit, Michigan 02034" in select list "Address"
    Then I click "Update Company person" button
    And I should be on the Company person 'ca@widgets.com' show page
    And I should see "12 Main Street Detroit, Michigan 02034"

  Scenario: company contact can update address
    Given I am on the home page
    And I login as "jane@widgets.com" with password "qwerty123"
    Then I press "edit-profile"
    And I do not have an address
    And I should see selections of "Widgets Inc." addresses
    And I should not see selections of "Feature Inc." addresses
    And I select "12 Main Street Detroit, Michigan 02034" in select list "Address"
    Then I click "Update Company person" button
    And I should be on the Company person 'jane@widgets.com' show page
    And I should see "12 Main Street Detroit, Michigan 02034"

  @javascript
  Scenario: verify people listing in home page
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I should be on the Company Person 'ca@widgets.com' Home page
    And I wait 2 seconds
    And I should see "Smith, John"
    And I should see "Smith, Jane"
    And I should not see "Daniel, Charles"

  @selenium
  Scenario: Company Contact with tasks on home page
    Given I am on the home page
    And I login as "jane@widgets.com" with password "qwerty123"
    And I should see "Your Open Tasks"
    And I should see "Review job application"
    And the task 1 status is "Assigned"
    Then I press the wip button of the task 1
    And I wait 5 seconds
    And I should see notification "Work on the task started"
    And the task 1 status is "Work in progress"
    Then I press the done button of the task 1
    And I wait 1 second
    And I should see notification "Work on the task is done"
    And the task 1 is not present
