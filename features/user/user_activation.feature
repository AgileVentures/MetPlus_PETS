
Feature: User activation
  As an User
  I want to activate my account

  Background: Users creation
    Given I have the following Job Seekers
      |first_name | email          | password | password_confirmation |
      |John       | johndoe@mail.fi| password1 | password1              |
      |Tom        | tom@mail.fi| password1 | password1              |
    Given no emails have been sent

  @javascript
  Scenario: User activation
    Given I go to the "activation for user 'tom@mail.fi'" page
    Then I should see "User activated. You can proceed to the login page to enter the application!"
    And I press "Log In"
    And I fill in the fields
      | Email                 | tom@mail.fi  |
      | Password              | password1    |
    And I press "Login"
    Then I should see "Hello, Tom"

  Scenario: Unable to find user
    Given I go to the "activation for user '123456'" page
    Then I should see "Unable to find user using that activation code!"