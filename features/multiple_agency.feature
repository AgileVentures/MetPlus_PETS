Feature: Support multiple agencies

  As a PETS administrator
  I want to support multiple agencies
  So that the application can be more widely used

  Background:
    Given the default settings are present
    Given the following agency people exist:
      | agency   | role  | first_name | last_name | email            | password  | phone        |
      | MetPlus  | AA    | John       | Smith     | aa@metplus.org   | qwerty123 | 555-222-3334 |
    Given I am logged in as agency admin

  Scenario: The agencies display name should appear on the menu
    When I am on the home page
    Then I should see "METPLUS"

  Scenario: Updated display name should appear on the menu
    When I go to the agency 'MetPlus' edit page
    And I fill in "Display name" with "METS|PLUS &#x1f680;"
    And I click "Update Agency" button
    Then I am on the home page
    And I should see "METS|PLUS &#x1f680;"

  Scenario: Displays Agency name when display name is blank
    When I go to the agency 'MetPlus' edit page
    And I fill in "Display name" with ""
    And I click "Update Agency" button
    Then I am on the home page
    And I should see "MetPlus"
