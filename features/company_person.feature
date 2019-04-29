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
      | agency  | name          | website      | phone        | email             | job_email         | ein        | status   |
      | MetPlus | Widgets Inc.  | widgets.com  | 555-222-3333 | corp@ymail.com    | corp@ymail.com    | 12-3456789 | active   |
      | MetPlus | Feature Inc.  | feature.com  | 555-222-3333 | corp@feature.com  | corp@feature.com  | 12-3456788 | active   |
      | MetPlus | Inactive Inc. | inactive.com | 555-222-3333 | corp@inactive.com | corp@inactive.com | 12-3456787 | inactive |

    Given the following job skills exist:
    | name            | description             | organization |
    | Web Research    | Hic deleniti explicabo. | Widgets Inc. |
    | Visual Analysis | Incidunt aut magni.     | Widgets Inc. |


    Given the following company addresses exist:
      | company       | street           | city    | zipcode | state      |
      | Widgets Inc.  | 12 Main Street   | Detroit | 02034   | Michigan   |
      | Widgets Inc.  | 14 Main Street   | Detroit | 02034   | Michigan   |
      | Feature Inc.  | 100 River Valley | Utah    | 12334   | New Jersey |
      | Feature Inc.  | 111 River Valley | Utah    | 12334   | New Jersey |

    Given the following company people exist:
      | company       | role  | first_name | last_name | email             | password  | phone        |
      | Widgets Inc.  | CA    | John       | Smith     | carter@ymail.com  | qwerty123 | 555-222-3334 |
      | Widgets Inc.  | CC    | Jane       | Smith     | jane@ymail.com    | qwerty123 | 555-222-3334 |
      | Feature Inc.  | CA    | Charles    | Daniel    | ca@feature.com    | qwerty123 | 555-222-3334 |
      | Inactive Inc. | CA    | Jean       | Xavier    | ca@inactive.com   | qwerty123 | 555-222-3334 |

    Given the following tasks exist:
      | task_type          | owner                | deferred_date | status      | targets               |
      | job_application    | jane@ymail.com     | 2016-03-10    | ASSIGNED    | john-seeker@gmail.com |

    Given the following jobs exist:
    | title         | company_job_id  | description | company      | creator          | skills    |
    | Web dev       | KRK01K          | internship  | Widgets Inc. | jane@ymail.com | Web Research |

  Scenario: company admin edits company info
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I should see "Edit Company Info"
    Then I click the "Edit Company Info" link
    Then I should see "Edit Company"
    And I fill in "Website" with "www.widgets-inc.com"
    And I click the "Submit" button
    Then I should see "company was successfully updated."

  @javascript
  Scenario: company admin can edit and delete company person
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I wait 1 seconds
    And I click the "All Widgets Inc. people who are on PETS" link
    And I wait 1 second
    Then I click the "Smith, Jane" link
    And I should see button "Edit Person"
    And I should see button "Delete Person"

  @javascript
  Scenario: company admin can edit but not delete himself
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I wait 1 second
    And I click the "All Widgets Inc. people who are on PETS" link
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
    And I click the "Companies" link
    Then I click the "Widgets Inc." link
    Then I click the "Smith, Jane" link
    And I should see button "Edit Person"
    And I should see button "Delete Person"
    And I click "Delete Person" button
    Then I accept the confirm dialog
    And I should see "Person 'Jane Smith' deleted."

  Scenario: company contact cannot edit company nor invite person_type
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I should not see "Edit Company Info"
    And I should not see "Invite Colleague"

  @javascript
  Scenario: company contact can view but not edit other company people
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I click the "All Widgets Inc. people who are on PETS" link
    And I wait 1 second
    Then I click the "Smith, John" link
    And I should not see button "Edit Person"
    And I should not see button "Delete Person"

    @intermittent-ci-js-fail
  Scenario: company admin login and edit profile from home page
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I should be on the Company Person 'carter@ymail.com' Home page
    And I click the "Hello, John" link
    Then I click the "My Profile" link
    And I should see "John"
    And I click the "Edit" link
    And I fill in "First Name" with "Tom"
    Then I click "Update Your Profile" button
    And I should see "Your profile was updated successfully."
    And I should not see "John"
    And I should see "Tom"

  Scenario: company admin login and edit email from home page
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I should be on the Company Person 'carter@ymail.com' Home page
    And I click the "Hello, John" link
    Then I click the "My Profile" link
    And I should see "John"
    And I click the "Edit" link
    And I fill in "Email" with "carter1@ymail.com"
    Then I click "Update Your Profile" button
    And I should see "Please check your inbox to update your email address."
    And I should not see "carter1@ymail.com"
    And I should see "carter@ymail.com"

  Scenario: company contact login and edit profile from home page
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I should be on the Company Person 'jane@ymail.com' Home page
    And I click the "Hello, Jane" link
    Then I click the "My Profile" link
    And I should see "Jane"
    Then I click the "Edit" link
    And I fill in "First Name" with "Mary"
    Then I click "Update Your Profile" button
    And I should see "Your profile was updated successfully."
    And I should not see "Jane"
    And I should see "Mary"

  Scenario: company contact cancel out of edit profile
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I should be on the Company Person 'jane@ymail.com' Home page
    And I click the "Hello, Jane" link
    And I click the "My Profile" link
    Then I click the "Edit" link
    And I should see "Update Your Profile"
    Then I click the "Cancel" link
    Then I should be on the Company Person 'jane@ymail.com' profile page

  Scenario: company contact login and edit profile from name
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I should be on the Company Person 'jane@ymail.com' Home page
    Then I press "Jane"
    And I am on the 'jane@ymail.com' edit profile page
    And I should see "Jane"
    And I fill in "First Name" with "Mary"
    Then I click "Update Your Profile" button
    And I should see "Your profile was updated successfully."
    And I should not see "Jane"
    And I should see "Mary"

  Scenario: company admin login and edit profile from name
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I should be on the Company Person 'carter@ymail.com' Home page
    Then I press "Hello, John"
    And I click the "My Profile" link
    And I click the "Edit" link
    And I am on the 'carter@ymail.com' edit profile page
    And I should see "John"
    And I fill in "First Name" with "Tom"
    Then I click "Update Your Profile" button
    And I should see "Your profile was updated successfully."
    And I should not see "John"
    And I should see "Tom"

  Scenario: company admin can update address
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I click the "Hello, John" link
    And I click the "My Profile" link
    Then I click the "Edit" link
    And I do not have an address
    And I should see selections of "Widgets Inc." addresses
    And I should not see selections of "Feature Inc." addresses
    And I select "12 Main Street Detroit, Michigan 02034" in select list "Address"
    Then I click "Update Your Profile" button
    And I should be on the Company person 'carter@ymail.com' show page
    And I should see "12 Main Street Detroit, Michigan 02034"

  Scenario: company contact can update address
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I click the "Hello, Jane" link
    And I click the "My Profile" link
    Then I click the "Edit" link
    And I do not have an address
    And I should see selections of "Widgets Inc." addresses
    And I should not see selections of "Feature Inc." addresses
    And I select "12 Main Street Detroit, Michigan 02034" in select list "Address"
    Then I click "Update Your Profile" button
    And I should be on the Company Person 'jane@ymail.com' Home page
    And I should see "Your profile was updated successfully."

  @javascript
  Scenario: verify people listing in home page
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"
    And I should be on the Company Person 'carter@ymail.com' Home page
    And I wait 2 seconds
    And I click the "All Widgets Inc. people who are on PETS" link
    And I should see "Smith, John"
    And I should see "Smith, Jane"
    And I should not see "Daniel, Charles"

  @javascript
  Scenario: Company Contact with tasks on home page
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I wait 1 second
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

  @javascript
  Scenario: manage job skills for company
    # add job skill
    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"
    And I wait 1 second
    And I click the "Job Skills" link
    And I click the "Add job skill" button
    And I fill in "Name:" with "Test Job Skill"
    And I fill in "Description:" with "Description of Test Job Skill"
    And I click the "Add Skill" button
    And I wait 1 second
    And I click the "Job Skills" link
    Then I should see "Test Job Skill"
    And I should see "Description of Test Job Skill"

    # cancel add job skill
    And I click the "Add job skill" button
    And I fill in "Name:" with "Test 2nd Job Skill"
    And I click the "Cancel" button
    Then I should not see "Test 2nd Job Skill"

    # show job skill model validation errors
    Then I click the "Add job skill" button
    And I fill in "Name:" with ""
    And I fill in "Description:" with ""
    And I click the "Add Skill" button
    Then I should see "Name can't be blank"
    And I should see "Description can't be blank"
    Then I fill in "Name:" with "Test 3rd Job Skill"
    And I fill in "Description:" with "Description of 3rd Test Job Skill"
    And I click the "Add Skill" button
    And I wait 1 second
    And I click the "Job Skills" link
    And I wait 1 second
    Then I should see "Test 3rd Job Skill"

    # update job skill
    And I click the "Web Research" link
    And I wait 1 second
    And I fill in "Description:" with ""
    And I click the "Update Skill" button
    And I wait 1 second
    And I should see "Description can't be blank"
    And I fill in "Description:" with "Analytics using web data"
    And I click the "Update Skill" button
    And I wait 1 second
    And I click the "Job Skills" link
    Then "Update Job Skill" should not be visible
    And I should see "Analytics using web data"

    # delete job skill not associated with a job
    And I click the "Delete" link with url "/skills/2"
    Then I should not see "Visual Analysis"

    # attempt to delete job skill associated with a job
    And I should not see the "/skills/1" link

  Scenario: Company person of inactive company cannot login
    Given  I am on the home page
    When I login as "ca@inactive.com" with password "qwerty123"
    Then I should see "Your company is no longer active in PETS"
