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
  
  Given the following agency branches exist:
  | agency  | city    | street              | zipcode | code |
  | MetPlus | Detroit | 123 Main Street     | 48201   | 001  |
  | MetPlus | Detroit | 456 Sullivan Street | 48204   | 002  |
  | MetPlus | Detroit | 3 Auto Drive        | 48206   | 003  |

Scenario: login as agency admin
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"

Scenario: go to main admin page
  Given I am logged in as agency admin
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
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Edit Agency" button
  Then I should see "MetPlus"
  And I fill in "Name" with "MetPlus Two"
  And I click "Update Agency" button
  Then I should see "Agency was successfully updated."
  And I should see "MetPlus Two"
  
Scenario: cancel edit agency information
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Edit Agency" button
  Then I should see "MetPlus"
  And I fill in "Name" with "MetPlus Two"
  And I click the "Cancel" link
  Then I should not see "Agency was successfully updated."
  And I should not see "MetPlus Two"
  
Scenario: errors for edit agency information
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Edit Agency" button
  Then I should see "MetPlus"
  And I fill in "Phone" with ""
  And I fill in "Website" with "nodomain"
  And I click "Update Agency" button
  Then I should see "errors prevented this record from being saved:"
  And I should see "Phone can't be blank"
  And I should see "Phone incorrect format"
  And I should see "Website is not a valid website address"
  
Scenario: edit branch
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I should see "Agency Branches"
  And I click the "001" link
  Then I should see "Branch Code:"
  And I should see "001"
  Then I click the "Edit Branch" button
  Then I should see "Edit Branch"
  And I fill in "Branch Code" with "004"
  And I click the "Update" button
  Then I should see "Branch was successfully updated."

Scenario: cancel edit branch
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "001" link
  Then I click the "Edit Branch" button
  Then I should see "Edit Branch"
  And I fill in "Branch Code" with "004"
  Then I click the "Cancel" link
  Then I should see "Agency Branch"
  And I should not see "004"

Scenario: error for edit branch
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "001" link
  Then I click the "Edit Branch" button
  And I fill in "Branch Code" with "002"
  And I fill in "Zipcode" with "1234567"
  And I click the "Update" button
  Then I should see "2 errors prevented this record from being saved:"
  And I should see "Code has already been taken"
  And I should see "Address zipcode should be in form of 12345 or 12345-1234"
  
Scenario: new agency branch
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "Add Branch" button
  Then I fill in "Branch Code" with "004"
  And I fill in "Street" with "10 Ford Way"
  And I fill in "City" with "Detroit"
  And I fill in "Zipcode" with "48208"
  And I click the "Create" button
  Then I should see "Branch was successfully created."
  And I should see "004"

@selenium
Scenario: delete agency branch
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "003" link
  Then I click the "Delete Branch" button
  And I confirm the popup dialog
  Then I should see "Branch '003' deleted."
  
Scenario: edit agency person
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I should see "Agency Personnel"
  And I click the "Jones, Jane" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Jane Jones"
  Then I select "002" in select list "Branch"
  And I check "Agency Admin"
  And I click the "Update" button
  Then I should see "Agency person was successfully updated."
  And I should see "Jane Jones"
  And I should see "002"
  And I should see "Agency Admin"
  
Scenario: cancel agency person edit
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "Jones, Jane" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Jane Jones"
  Then I select "002" in select list "Branch"
  Then I click the "Cancel" link
  Then I should see "Jane Jones"
  And I should not see "002"

@selenium
Scenario: delete agency person
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "Jones, Jane" link
  Then I click the "Delete Person" button
  And I confirm the popup dialog
  Then I should see "Person 'Jane Jones' deleted."
  
Scenario: cannot remove sole agency admin
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "Smith, John" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: John Smith"
  And I should see "Agency Admin"
  And the selection "Agency Admin" should be disabled
  
Scenario: invite (and reinvite) new agency person
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Invite Person" link
  And I should see "Send invitation"
  And I fill in "Email" with "adam@metplus.org"
  And I fill in "First name" with "Adam"
  And I fill in "Last name" with "Powell"
  And I click the "Send an invitation" button
  And I should see "An invitation email has been sent to adam@metplus.org."
  And I should see "Edit Agency Person: Adam Powell"
  And I click the "Cancel" link
  Then I should see "Agency Person"
  And I click the "invite again" link
  And I should see "An invitation email has been sent to adam@metplus.org."
  Then "adam@metplus.org" should receive 2 emails with subject "Invitation instructions"
  When "adam@metplus.org" opens the email
  Then they should see "MetPlus has invited you confirm your account in PETS" in the email body
  
Scenario: agency person accepts invitation in email
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Invite Person" link
  And I fill in "Email" with "adam@metplus.org"
  And I fill in "First name" with "Adam"
  And I fill in "Last name" with "Powell"
  And I click the "Send an invitation" button
  And I should see "An invitation email has been sent to adam@metplus.org."
  And I log out
  Then "adam@metplus.org" should receive 1 email with subject "Invitation instructions"
  When "adam@metplus.org" opens the email
  Then they should see "Accept invitation" in the email body
  And "adam@metplus.org" follows "Accept invitation" in the email
  Then they should see "Set your password"
  And they fill in "Password" with "qwerty123"
  And they fill in "Password confirmation" with "qwerty123"
  And they click the "Set my password" button
  Then they should see "Your password was set successfully. You are now signed in."
  