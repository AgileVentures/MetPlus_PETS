Feature: management of company registrations

  As an agency admin
  I want to manage company registration request

Background: seed data added to database

  Given the following agency roles exist:
  | role  |
  | AA    |
  | JD    |
  | CM    |

  Given the following agencies exist:
  | name    | website     | phone        | email                  | fax          |
  | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |

  Given the following company registration exist:
  | company name  | ein        | first_name | last_name | title       | contact | email |
  | Widgets, Inc. | 12-3456789 |   Hugh     | Jobs      | HR Director | 555-555-1212 | hughjobs@ymail.com |

Scenario: approve company registration
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Widgets, Inc." link
  Then I should see "Pending Registration"
  And I click the "Approve" link
  Then I should see "Company contact has been notified of registration approval."
  Then "hughjobs@ymail.com" should receive an email with subject "Registration approved"
  When "hughjobs@ymail.com" opens the email with subject "Registration approved"
  Then they should see "Your registration of Widgets, Inc. in PETS has been approved." in the email body
  And "hughjobs@ymail.com" should receive an email with subject "Confirmation instructions"
  When "hughjobs@ymail.com" opens the email with subject "Confirmation instructions"
  Then they should see "You can confirm your account email through the link below:" in the email body

@javascript
Scenario: delete company registration and response seen by the deleted company person
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Widgets, Inc." link
  And I should see "Pending Registration"
  Then I click and accept the "Delete Registration" button
  And I wait 1 second
  Then I should see "Registration for 'Widgets, Inc.' deleted."
  And I click the "Hello, John" link
  And I log out
  And I wait 1 second
  Then I am on the home page
  And I login as "hughjobs@ymail.com" with password "qwerty123"
  Then I should see "Invalid email or password."

@javascript
Scenario: company registration denial and response seen by the denied company person
  Given I am logged in as agency admin
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Widgets, Inc." link
  And I should see "Pending Registration"
  And I click the "Deny" button
  Then I should see "Explanation for registration denial"
  And I fill in "Explanation:" with "We are not accepting additional partners at this time."
  And I click the "Send email" button
  And I wait 7 seconds
  Then I should see "Registration Denied"
  Then "hughjobs@ymail.com" should receive an email with subject "Registration denied"
  And I click the "Hello, John" link
  And I log out
  And I wait 1 second
  Then I am on the home page
  And I login as "hughjobs@ymail.com" with password "qwerty123"
  Then I should see "Your company registration has been denied."

Scenario: edit Company Registration: change contact email, job email and password
  Given I am logged in as agency admin
  And a clear email queue
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Widgets, Inc." link
  Then I should see "Pending Registration"
  And I click the "Edit Registration" button
  And I should see "Edit Company Registration"
  Then I fill in "Company Name" with "Gizmos, Inc."
  And I fill in "Contact Email" with "hughjobs@gmail.com"
  And I fill in "Job Email" with "goodjobs@gmail.com"
  And I click the "Update" button
  Then I should see "Registration was successfully updated."
  Then "hughjobs@ymail.com" should have no emails
  And "hughjobs@gmail.com" should receive 1 email with subject "Pending approval"
  Then "hughjobs@gmail.com" opens the email
  And they should see "Thank you for registering Gizmos, Inc. in PETS." in the email body
  Then I click the "Gizmos, Inc." link
  And I click the "Edit Registration" button
  And I should see "Edit Company Registration"
  Then I fill in "Password" with "abcd1234"
  Then I fill in "Password Confirmation" with "abcd1234"
  And I click the "Update" button
  Then I should see "Registration was successfully updated."
  Then "hughjobs@ymail.com" should have no emails
