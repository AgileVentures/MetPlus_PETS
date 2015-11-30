Feature: agency admin logs in and performs admin functions

  As an agency admin
  I want to login to PETS
  And perform various administrative functions
    
Background: seed data added to database

  Given the following agency roles exist:
  | role  |
  | AA    |
  | CM    |
  
  Given the following agencies exist:
  | name    | website     | phone        | email                  | fax          |
  | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |
  
  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 |
  
  Given the following agency addresses exist:
  | agency  | city    | street              | zipcode |
  | MetPlus | Detroit | 123 Main Street     | 48201   |
  | MetPlus | Detroit | 456 Sullivan Street | 48204   |
  | MetPlus | Detroit | 3 Auto Drive        | 48206   |

Scenario: login as agency admin
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"

Scenario: go to main admin page
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  And I click the "Admin" link
  Then I should see "PETS Administration"
  And I should see "Agency Information"
  And I should see "Agency Branches"
  And I should see "Agency Personnel"
  And I should see "Auto Drive"

Scenario: non-admin does not see 'admin' in menu
  Given I am on the home page
  And I login as "jane@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should not see "Admin"
  
Scenario: edit agency information
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  And I click the "Admin" link
  Then I click the "Edit Agency" link
  Then I should see "MetPlus"
  And I fill in "Name" with "MetPlus Two"
  And I click "Update Agency" button
  Then I should see "Agency was successfully updated."
  And I should see "MetPlus Two"
  
Scenario: cancel edit agency information
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  And I click the "Admin" link
  Then I click the "Edit Agency" link
  Then I should see "MetPlus"
  And I fill in "Name" with "MetPlus Two"
  And I click "Cancel" button
  Then I should not see "Agency was successfully updated."
  And I should not see "MetPlus Two"
  
Scenario: errors for edit agency information
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  And I click the "Admin" link
  Then I click the "Edit Agency" link
  Then I should see "MetPlus"
  And I fill in "Phone" with ""
  And I fill in "Website" with "nodomain"
  And I click "Update Agency" button
  Then I should see "errors prevented this record from being saved:"
  And I should see "Phone can't be blank"
  And I should see "Phone incorrect format"
  And I should see "Website is not a valid website address"
