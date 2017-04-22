Feature: company registrations request

  As a visitor to PETS
  I want to request registration of my company as a partner with the agency

Background: seed data added to database

  Given the following agency roles exist:
  | role  |
  | AA    |
  | JD    |
  | CM    |

  Given the following company roles exist:
  | role  |
  | CA    |

  Given the following agencies exist:
  | name    | website     | phone        | email                  | fax          |
  | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |

  Given I am on the home page
  And I click the "Register as an Employer" link
  And I wait 1 second
  Then I should see "Company Registration"
  And I fill in the fields:
  | Company Name                   | Widgets, Inc.       |
  | Street                         | 12 Main Street      |
  | City                           | Detroit             |
  | Zipcode                        | 02034               |
  | Email                          | contact@ymail.com |
  | Job Email                      | jobs@ymail.com    |
  | Fax                            | 333-222-4321        |
  | Phone                          | 222-333-4567        |
  | Website                        | www.widgets.com     |
  | EIN                            | 12-3456789          |
  | Description                    | Widgets are us!     |
  | Title                          | HR Director         |
  | First Name                     | Hugh                |
  | Last Name                      | Jobs                |
  | Contact Phone                  | 555-555-1212        |
  | Contact Email                  | hughjobs@ymail.com|
  | Password                       | qwerty123           |
  | Password Confirmation          | qwerty123           |
  And  I select "Michigan" in select list "State"

Scenario: company registration request
  And I click the "Create" button
  Then I should see "Thank you for your registration request."
  And I should see "We also sent you an email with more information"
  Then "hughjobs@ymail.com" should receive 1 email with subject "Pending approval"
  When "hughjobs@ymail.com" opens the email
  Then they should see "Thank you for registering Widgets, Inc. in PETS." in the email body

Scenario: attempt login while registration is pending
  And I click the "Create" button
  Given I am on the home page
  And I login as "hughjobs@ymail.com" with password "qwerty123"
  Then I should see "You have successfully signed up but your account cannot be used until your company registration is approved."

Scenario: duplicate EIN for Company
  And I click the "Create" button
  Given I am on the home page
  And I click the "Register as an Employer" link
  And I wait 1 second
  Then I should see "Company Registration"
  And I fill in the fields:
  | Company Name                   | Widgets, Inc.       |
  | Street                         | 12 Main Street      |
  | City                           | Detroit             |
  | Zipcode                        | 02034               |
  | Email                          | contact@ymail.com |
  | Phone                          | 222-333-4567        |
  | Fax                            |                     |
  | Website                        | www.widgets.com     |
  | EIN                            | 12-3456789          |
  | Description                    | Widgets are us!     |
  | Title                          | HR Director         |
  | First Name                     | Hugh                |
  | Last Name                      | Jobs                |
  | Contact Phone                  | 555-555-1212        |
  | Contact Email                  | hughjobs@ymail.com|
  | Password                       | qwerty123           |
  | Password Confirmation          | qwerty123           |
  And  I select "Michigan" in select list "State"
  And I click the "Create" button
  Then I should see "Ein has already been registered"

Scenario: cancel out of registration form
  And I click the "Cancel" link
  Then I should be on the home page
