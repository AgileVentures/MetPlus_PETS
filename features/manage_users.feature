Feature: Manage Users

  As a user
  I want to login
  So that I can edit my profiles

  #@focus
  Background:

    Given the default settings are present

    Given the following agency people exist:
    | agency  | role  | first_name | last_name | email            | password  |
    | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
    | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 |

    Given the following user records:
    | email               | password   | password_confirmation | first_name | last_name | phone          | confirmed_at                      |
    | salemamba@gmail.com | secret1234 | secret1234            | salem      | amba      | (619) 123-1234 | "Sat, 14 Nov 2015 22:52:26 -0800" |

  Scenario Outline: Updating User successfully
    Given I am on the home page
    And I am logged in as "<email>" with password "secret1234"
    And   I visit profile for "salem"
    Then  I should see "Edit User"

      When  I fill in the fields:
      | Password              | newsecret1234 |
      | Password confirmation | newsecret1234 |
      | Current password      | secret1234    |
      | First name            | Jon           |
      | Last name             | Doe           |
      | Phone                 | 714-123-1234  |

    And   I press "Update"
    Then  I should see "Your account has been updated successfully."
    And   I should verify the change of first_name "Jon", last_name "Doe" and phone "714-123-1234"

    Examples:
      | email               |
      | salemamba@gmail.com |

  Scenario: One canceling login page
    Given I am on the Jobseeker Registration page
    And I press "Log In"
    Then I press "Cancel"
    And I should be on the Jobseeker Registration page

  Scenario: Two canceling login page
    Given I am on the home page
    And I press "Log In"
    Then I press "Cancel"
    And I should be on the home page
  # maybe fail after cancancan implementation

  # Scenario removed because now the users are redirected to they page
  #Scenario: Redirecting back to previous page after successfull login
  #  Given I am on the Company Registration page
  #  And I am logged in as "<email>" with password "secret1234"
  #  And I should be on the Company Registration page

  Scenario: Confirmation of user email (and duplicate confirm)
    Given I am on the Jobseeker Registration page
    And I fill in the fields:
    | First Name            | Joseph          |
    | Last Name             | Smith           |
    | Email                 | jsmith@mail.com |
    | Phone                 | 111-222-3333    |
    | Password              | qwerty123       |
    | Password Confirmation | qwerty123       |
    And I select "1980" in select list "Year Of Birth"

    And I select "Employed Looking" in select list "Status"
    And I click the "Create Job seeker" button
    Then I should see "A message with a confirmation and link has been sent to your email address."
    And "jsmith@mail.com" should receive an email with subject "Confirmation instructions"
    When I open the email
    Then I should see "Confirm my account" in the email body
    And I follow "Confirm my account" in the email
    Then I should see "Your email address has been successfully confirmed."
    And I follow "Confirm my account" in the email
    Then I should see "Your email address has been successfully confirmed."

Scenario: Resend confirmation email - happy path
  Given I am on the Jobseeker Registration page
  And I fill in the fields:
  | First Name            | Joseph          |
  | Last Name             | Smith           |
  | Email                 | jsmith@mail.com |
  | Phone                 | 111-222-3333    |
  | Password              | qwerty123       |
  | Password Confirmation | qwerty123       |
  And I select "1980" in select list "Year Of Birth"

  And I select "Employed Looking" in select list "Status"
  And I click the "Create Job seeker" button
  And I should see "A message with a confirmation and link has been sent to your email address."
  Then I click the "Log In" link
  And I click the "Didn't receive confirmation instructions?" link
  And I fill in "Email" with "jsmith@mail.com"
  Then I click the "Resend confirmation instructions" button
  And I should see "You will receive an email with instructions for how to confirm your email address in a few minutes."
  And "jsmith@mail.com" should receive 2 emails with subject "Confirmation instructions"
  Then I open the email
  And I follow "Confirm my account" in the email
  Then I should see "Your email address has been successfully confirmed."

Scenario: Resend confirmation email - sad path
  Given I am on the Jobseeker Registration page
  And I fill in the fields:
  | First Name            | Joseph          |
  | Last Name             | Smith           |
  | Email                 | jsmith@mail.com |
  | Phone                 | 111-222-3333    |
  | Password              | qwerty123       |
  | Password Confirmation | qwerty123       |
  And I select "1980" in select list "Year Of Birth"

  And I select "Employed Looking" in select list "Status"
  And I click the "Create Job seeker" button
  And I should see "A message with a confirmation and link has been sent to your email address."
  And "jsmith@mail.com" should receive an email with subject "Confirmation instructions"
  Then I open the email
  And I follow "Confirm my account" in the email
  Then I should see "Your email address has been successfully confirmed."
  And I should see "Log in"
  Then I click the "Didn't receive confirmation instructions?" link
  And I fill in "Email" with "jsmith@mail.com"
  And I click the "Resend confirmation instructions" button
  Then I should see "1 error prevented resending a confirmation email:"
  And I should see "Email was already confirmed, please try signing in"

  @javascript
  Scenario: Do not remember user on login
    Given I am on the home page
    Then I click the "Log In" link
    And I fill in "user_email" with "salemamba@gmail.com"
    And I fill in "user_password" with "secret1234"
    And I click "Log in" button
    Then I should not be remembered

  @javascript
  Scenario: Remember user on log in
    Given I am on the home page
    Then I click the "Log In" link
    And I fill in "user_email" with "salemamba@gmail.com"
    And I fill in "user_password" with "secret1234"
    And I check "user_remember_me"
    And I click "Log in" button
    Then I should be remembered

  @javascript
  Scenario: User logs out
    Given I am on the home page
    And I login as "salemamba@gmail.com" with password "secret1234"
    And I click the "dd_menu" link
    Then I log out
    Then I should be logged out
