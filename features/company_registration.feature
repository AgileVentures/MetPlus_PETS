Feature: management of company registrations

  As a visitor to PETS
  I want to request registration of my company as a partner with the agency
  And as an agency admin
  I want to manage registration requests

Background: seed data added to database

  Given the following agency roles exist:
  | role  |
  | AA    |

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
  And I click the "Become a hiring partner!" link
  And I wait 1 second
  Then I should see "Company Registration"
  And I fill in the fields:
  | Company Name                   | Widgets, Inc.       |
  | Company Address                | 12 Main Street      |
  | City                           | Detroit             |
  | Zipcode                        | 02034               |
  | Email                          | contact@widgets.com |
  | Phone                          | 222-333-4567        |
  | Company Website                | www.widgets.com     |
  | Employer Identification Number | 12-3456789          |
  | Description                    | Widgets are us!     |
  | Title                          | HR Director         |
  | First Name                     | Hugh                |
  | Last Name                      | Jobs                |
  | Contact Phone                  | 555-555-1212        |
  | Contact Email                  | hughjobs@widgets.com|
  | Password                       | qwerty123           |
  | Password Confirmation          | qwerty123           |
  And I click the "Create" button

Scenario: company registration request
  Then I should see "Thank you for your registration request."
  And I should see "We also sent you an email with more information"
  Then "hughjobs@widgets.com" should receive 1 email with subject "Pending approval"
  When "hughjobs@widgets.com" opens the email
  Then they should see "Thank you for registering Widgets, Inc. in PETS." in the email body

Scenario: attempt login while registration is pending
  Given I am on the home page
  And I login as "hughjobs@widgets.com" with password "qwerty123"
  Then I should see "You have successfully signed up but your account cannot be used until your company registration is approved."

Scenario: company registration approval
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Widgets, Inc." link
  Then I should see "Pending Registration"
  And I click the "Approve" link
  Then I should see "Company contact has been notified of registration approval."
  Then "hughjobs@widgets.com" should receive an email with subject "Registration approved"
  When "hughjobs@widgets.com" opens the email with subject "Registration approved"
  Then they should see "Your registration of Widgets, Inc. in PETS has been approved." in the email body
  And "hughjobs@widgets.com" should receive an email with subject "Confirmation instructions"
  When "hughjobs@widgets.com" opens the email with subject "Confirmation instructions"
  Then they should see "You can confirm your account email through the link below:" in the email body

@javascript
Scenario: company registration delete
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Widgets, Inc." link
  And I should see "Pending Registration"
  Then I click and accept the "Delete Registration" button
  Then I should see "Registration for 'Widgets, Inc.' deleted."

@javascript
Scenario: attempt login after registration is deleted
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Widgets, Inc." link
  Then I click and accept the "Delete Registration" button
  And I log out
  Then I am on the home page
  And I login as "hughjobs@widgets.com" with password "qwerty123"
  Then I should see "Invalid email or password."

@javascript
Scenario: company registration denial
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Widgets, Inc." link
  And I should see "Pending Registration"
  And I click the "Deny" button
  Then I should see "Explanation for registration denial"
  And I fill in "Explanation:" with "We are not accepting additional partners at this time."
  And I click the "Send email" button
  And I wait 3 seconds
  Then I should see "Registration Denied"
  Then "hughjobs@widgets.com" should receive an email with subject "Registration denied"

@javascript
Scenario: attempt login after registration is denied
  Given I am logged in as agency admin
  And I click the "Admin" link
  Then I click the "Widgets, Inc." link
  And I should see "Pending Registration"
  And I click the "Deny" button
  And I fill in "Explanation:" with "We are not accepting additional partners at this time."
  And I click the "Send email" button
  And I log out
  Then I am on the home page
  And I login as "hughjobs@widgets.com" with password "qwerty123"
  Then I should see "Your company registration has been denied."

Scenario: duplicate EIN for Company
  Given I am on the home page
  And I click the "Become a hiring partner!" link
  And I wait 1 second
  Then I should see "Company Registration"
  And I fill in the fields:
  | Company Name                   | Widgets, Inc.       |
  | Company Address                | 12 Main Street      |
  | City                           | Detroit             |
  | Zipcode                        | 02034               |
  | Email                          | contact@widgets.com |
  | Phone                          | 222-333-4567        |
  | Company Website                | www.widgets.com     |
  | Employer Identification Number | 12-3456789          |
  | Description                    | Widgets are us!     |
  | Title                          | HR Director         |
  | First Name                     | Hugh                |
  | Last Name                      | Jobs                |
  | Contact Phone                  | 555-555-1212        |
  | Contact Email                  | hughjobs@widgets.com|
  | Password                       | qwerty123           |
  | Password Confirmation          | qwerty123           |
  And I click the "Create" button
  Then I should see "Ein has already been registered"

Scenario: edit Company Registration: change contact email
  Given I am logged in as agency admin
  And a clear email queue
  And I click the "Admin" link
  Then I click the "Widgets, Inc." link
  Then I should see "Pending Registration"
  And I click the "Edit Registration" button
  And I should see "Edit Company Registration"
  Then I fill in "Company Name" with "Gizmos, Inc."
  And I fill in "Contact Email" with "hughjobs@gizmos.com"
  And I click the "Update" button
  Then I should see "Registration was successfully updated."
  Then "hughjobs@widgets.com" should have no emails
  And "hughjobs@gizmos.com" should receive 1 email with subject "Pending approval"
  Then "hughjobs@gizmos.com" opens the email
  And they should see "Thank you for registering Gizmos, Inc. in PETS." in the email body

Scenario: edit Company Registration: change contact password
  Given I am logged in as agency admin
  And a clear email queue
  And I click the "Admin" link
  Then I click the "Widgets, Inc." link
  Then I should see "Pending Registration"
  And I click the "Edit Registration" button
  And I should see "Edit Company Registration"
  Then I fill in "Password" with "abcd1234"
  Then I fill in "Password Confirmation" with "abcd1234"
  And I click the "Update" button
  Then I should see "Registration was successfully updated."
  Then "hughjobs@widgets.com" should have no emails
