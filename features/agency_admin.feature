Feature: agency admin logs in and performs admin functions

  As an agency admin
  I want to login to PETS
  And perform various administrative functions

Background: seed data added to database and log in as agency admim

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

  Given the following agency branches exist:
  | agency  | city    | street              | zipcode | code |
  | MetPlus | Detroit | 123 Main Street     | 48201   | 001  |
  | MetPlus | Detroit | 456 Sullivan Street | 48204   | 002  |
  | MetPlus | Detroit | 3 Auto Drive        | 48206   | 003  |

  Given the following job categories exist:
  | name                      | description                         |
  | Software Engineer - RoR   | Develop website using Ruby on Rails |

  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"
  And I click the "Admin" link

@javascript
Scenario: toggle data tables - home page
  And I click the "Agency and Partner Companies" link
  And I wait 1 second
  And I should see "123 Main Street"
  Then I click the "Hide Branches" link
  And I wait 1 second
  Then "123 Main Street" should not be visible
  Then I click the "Show Branches" link
  And I wait 1 second
  Then "123 Main Street" should be visible
  And I should see "Smith, John"
  Then I click the "Hide People" link
  And I wait 1 second
  Then "Smith, John" should not be visible
  Then I click the "Show People" link
  And I wait 1 second
  Then "Smith, John" should be visible

@javascript
Scenario: toggle data tables - job properties page
  And I click the "Job Properties" link
  And I wait 1 second
  And I should see "Software Engineer - RoR"
  Then I click the "Hide Job Categories" link
  And I wait 1 second
  Then "Software Engineer - RoR" should not be visible
  Then I click the "Show Job Categories" link
  And I wait 1 second
  Then "Software Engineer - RoR" should be visible


Scenario: edit agency information
  And I click the "Agency and Partner Companies" link
  Then I should see "PETS Administration"
  Then I click the "Edit Agency" button
  Then I should see "MetPlus"
  And I fill in "Name" with "MetPlus Two"
  And I click "Update Agency" button
  Then I should see "Agency was successfully updated."
  And I should see "MetPlus Two"

Scenario: cancel edit agency information
  And I click the "Agency and Partner Companies" link
  Then I click the "Edit Agency" button
  Then I should see "MetPlus"
  And I fill in "Name" with "MetPlus Two"
  And I click the "Cancel" link
  Then I should not see "Agency was successfully updated."
  And I should not see "MetPlus Two"

Scenario: errors for edit agency information
  And I click the "Agency and Partner Companies" link
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
  And I click the "Agency and Partner Companies" link
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
  And I click the "Agency and Partner Companies" link
  And I click the "001" link
  Then I click the "Edit Branch" button
  Then I should see "Edit Branch"
  And I fill in "Branch Code" with "004"
  Then I click the "Cancel" link
  Then I should see "Agency Branch"
  And I should not see "004"

Scenario: error for edit branch
  And I click the "Agency and Partner Companies" link
  And I click the "001" link
  Then I click the "Edit Branch" button
  And I fill in "Branch Code" with "002"
  And I fill in "Zipcode" with "1234567"
  And I click the "Update" button
  Then I should see "2 errors prevented this record from being saved:"
  And I should see "Code has already been taken"
  And I should see "Address zipcode should be in form of 12345 or 12345-1234"

Scenario: new agency branch
  And I click the "Agency and Partner Companies" link
  And I click the "Add Branch" button
  Then I fill in "Branch Code" with "004"
  And I fill in "Street" with "10 Ford Way"
  And I fill in "City" with "Detroit"
  And I fill in "Zipcode" with "48208"
  And I click the "Create" button
  Then I should see "Branch was successfully created."
  And I should see "004"

@javascript
Scenario: delete agency branch
  And I click the "Agency and Partner Companies" link
  And I click the "003" link
  Then I click and accept the "Delete Branch" button
  And I wait for 3 seconds
  Then I should see "Branch '003' deleted."

Scenario: edit agency person
  And I click the "Agency and Partner Companies" link
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
  And I click the "Agency and Partner Companies" link
  And I click the "Jones, Jane" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Jane Jones"
  Then I select "002" in select list "Branch"
  Then I click the "Cancel" link
  Then I should see "Jane Jones"
  And I should not see "002"

@javascript
Scenario: delete agency person
  And I click the "Agency and Partner Companies" link
  And I click the "Jones, Jane" link
  Then I click and accept the "Delete Person" button
  And I wait for 3 seconds
  Then I should see "Person 'Jane Jones' deleted."

Scenario: cannot remove sole agency admin
  And I click the "Agency and Partner Companies" link
  And I click the "Smith, John" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: John Smith"
  And I should see "Agency Admin"
  And the selection "Agency Admin" should be disabled

Scenario: non-admin does not see 'admin' in menu
  And I click the "Agency and Partner Companies" link
  Given I log out
  Given I am on the home page
  And I login as "jane@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should not see "Admin"

@selenium
Scenario: add job category
  And I click the "Job Properties" link
  And I click the "Add Job Category" button
  And I wait 2 seconds
  And I fill in "Name:" with "Test Job Category"
  And I fill in "Description:" with "Description of Test Job Category"
  And I click the "Add Category" button
  And I wait 2 seconds
  Then I should see "Test Job Category"
  And I should see "Description of Test Job Category"

@selenium
Scenario: cancel add job category
  And I click the "Job Properties" link
  And I click the "Add Job Category" button
  And I wait 2 seconds
  And I fill in "Name:" with "Test Job Category"
  And I click the "Cancel" button
  And I wait 2 seconds
  Then I should not see "Test Job Category"
  And I should not see "Description of Test Job Category"

@selenium
Scenario: show job category model validation errors
  And I click the "Job Properties" link
  And I click the "Add Job Category" button
  And I wait 2 seconds
  And I click the "Add Category" button
  And I wait 2 seconds
  Then I should see "Name can't be blank"
  And I should see "Description can't be blank"
  Then I fill in "Name:" with "Test Job Category"
  And I fill in "Description:" with "Description of Test Job Category"
  And I click the "Add Category" button
  And I wait 2 seconds
  Then I should see "Test Job Category"
  And I should see "Description of Test Job Category"

@selenium
Scenario: update job category
  And I click the "Job Properties" link
  And I click the "Software Engineer - RoR" link
  And I wait 2 seconds
  And I fill in "Description:" with ""
  And I click the "Update Category" button
  And I should see "Description can't be blank"
  And I fill in "Description:" with "Backend RoR Development"
  And I click the "Update Category" button
  And I wait 2 seconds
  Then "Update Job Category" should not be visible
  And I should see "Backend RoR Development"

@selenium
Scenario: delete job category
  And I click the "Job Properties" link
  And I click the link with url "/job_categories/1"
  And I wait 2 seconds
  Then I should not see "Software Engineer - RoR"
  And I should see "There are no job categories."
