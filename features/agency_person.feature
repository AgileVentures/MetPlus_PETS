Feature: Agency Person

  As a user
  I want to login
  So that I can edit my information

  Background:
    Given the following agency roles exist:
      | role  |
      | AA    |
      | CM    |
      | JD    |

    Given the following agencies exist:
      | name    | website     | phone        | email                  | fax          |
      | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

    Given the following agency people exist:
      | agency  | role  | first_name | last_name | email            | password  |  phone       |
      | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 | 555-222-3334 |
      | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 | 555-222-3334 |

    Given the following company roles exist:
      | role  |
      | CA    |
      | CC    |

    Given the following companies exist:
      | agency  | name         | website     | phone        | email            | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email            | password  | phone        |
      | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
      | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |

  Scenario: Agency Person login and edit from home page
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'jane@metplus.org' Home page
    And I should see "Your Job Seekers (Case Manager)"
    And I should not see "Job Seekers Without a Job Developer"
    Then I press "edit-profile"
    And I should see "Jane"
    And I fill in "First Name" with "Samantha"
    Then I click "Update Agency person" button
    And I should see "Your profile was updated successfully."
    And I should not see "Jane"
    And I should see "Samantha"
