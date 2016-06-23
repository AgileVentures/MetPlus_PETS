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
      | agency  | name         | website     | phone        | email            | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |
      | MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | 12-3456788 | Active |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email            | password  | phone        |
      | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
      | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |
      | Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |

    Given the following jobs exist:
      | title               | company_job_id  | shift  | fulltime | description                 | company      | creator        |
      | software developer  | KRK01K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK02K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK03K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK04K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK05K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK06K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK07K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK08K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK09K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | software developer  | KRK10K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK11K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Doctor              | AAEE1K          | Evening| true     | internship position with pay| Feature Inc. | ca@feature.com |
      | Cook                | KRK12K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK13K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK14K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK15K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK16K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK17K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK18K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK19K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |
      | Cook                | KRK20K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |

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

  @javascript
  Scenario: verify job listing in home page
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I should be on the Company Person 'ca@widgets.com' Home page
    And I wait for 5 seconds
    And I should see "Cook"
    And I should not see "Doctor"
    And I should not see "software developer"

  @javascript
  Scenario: verify people listing in home page
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    And I should be on the Company Person 'ca@widgets.com' Home page
    And I wait 2 seconds
    And I should see "Smith, John"
    And I should see "Smith, Jane"
    And I should not see "Daniel, Charles"
