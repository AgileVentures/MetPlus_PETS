Feature: User Registration
  As an Job Seeker
  I want to register to the website
  In order to check jobs

  Background: Users creation
    Given I have the following Job Seekers
      | email          | password | password_confirmation |
      | test@email.com | password | password              |
    Given no emails have been sent

  @javascript
  Scenario: Register successful
    Given I go to the "homepage" page
    And I press "New user"
    When I fill in the fields
      | First name            | John |
      | Last name             | Doe  |
      | Email                 | johndoe@place.com  |
      | Password              | 12345678|
      | Password confirmation | 12345678|
    And I press "Register"
    Then I should see "Registration successful"
    And I should see "email to active your account"
    And "johndoe@place.com" should receive an email
  @javascript
  Scenario: Register error(missing email and password)
    Given I go to the "homepage" page
    And I press "New user"
    When I fill in the fields
      | First name | John |
      | Last name  | Doe  |
    And I press "Register"
    Then I should see "can't be blank" between "Email" and "Password"
    And I should see "is not formatted properly" between "Email" and "Password"
    And I should see "can't be blank" between "Password" and "Password confirmation"
  @javascript
  Scenario: Register error(password mismatch)
    Given I go to the "homepage" page
    And I press "New user"
    When I fill in the fields
      | First name | John |
      | Last name  | Doe  |
      | Email      | johndoe@place.com |
      | Password   | 12345678            |
      | Password confirmation | 1234567|
    And I press "Register"
    Then I should see "doesn't match Password" between "Password confirmation" and "Job search status"
    And "johndoe@place.com" should receive no email
  @javascript
  Scenario: Register error(invalid email)
    Given I go to the "homepage" page
    And I press "New user"
    When I fill in the fields
      | First name | John |
      | Last name  | Doe  |
      | Email      | johndoe |
      | Password   | 12345678            |
      | Password confirmation | 12345678|
    And I press "Register"
    Then I should see "is not formatted properly" between "Email" and "Password"