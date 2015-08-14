Feature: User Registration
  As an Job Seeker
  I want to register to the website
  In order to check jobs

  Background: Users creation
    Given I have the following Job Seekers
      |first_name | email          | password | password_confirmation |
      |tester     | test@email.com | password1 | password1              |
      |John       | johndoe@mail.fi| password1 | password1              |
    Given no emails have been sent
    Given I activate user "test@email.com"

  @javascript
  Scenario: Login successful
    Given I go to the "homepage" page
    And I press "Log In"
    When I fill in the fields
      | Email                 | test@email.com  |
      | Password              | password1|
    And I press "Login"
    Then I should see "Hello tester"

  @javascript
  Scenario: Invalid password
    Given I go to the "homepage" page
    And I press "Log In"
    When I fill in the fields
      | Email                 | test@email.com  |
      | Password              | password|
    And I press "Login"
    Then I should see "Email and password do not match"

  @javascript
  Scenario: User not activated
    Given I go to the "homepage" page
    And I press "Log In"
    When I fill in the fields
      | Email                 | johndoe@mail.fi  |
      | Password              | password|
    And I press "Login"
    Then I should see "User is not activated"