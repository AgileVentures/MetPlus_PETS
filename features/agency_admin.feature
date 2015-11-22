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
  | name    | website     | phone        | email                  |
  | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org |
  
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
