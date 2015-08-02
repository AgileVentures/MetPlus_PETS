Feature: User Registration
  As an Job Seeker
  I want to register to the website
  In order to check jobs

  Background: Users creation
    Given I have the following Job Seekers
      | email          | password |
      | test@email.com | password |

  Scenario: Register successful
    Given I go to the registration page
    When I fill in the fields
      | First name | John |
      | Last Name  | Doe  |
      | Email      | johndoe@place.com |
      | Password   | 123456            |
      | Password(Again) | 123456       |
    And I press "Register"
    Then I should see "Registration successful"
    And I should see "activation email"