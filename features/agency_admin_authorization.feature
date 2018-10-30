Feature: Access agency admin when not a valid administrator

  As an none agency admin
  I want to login to PETS
  And not be allowed to perform agency administrative functions

  Background: seed data added to database and log in as agency admim

    Given the following agency roles exist:
      | role  |
      | AA    |
      | CM    |
      | JD    |

    Given the following agencies exist:
      | name    | website     | phone        | email                  | fax          |
      | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

    Given the following agency people exist:
      | agency  | role  | first_name | last_name | email            | password  |
      | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
      | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 |
    
    Given the following agency branches exist:
      | agency  | city    | street              | zipcode |  state   | code |
      | MetPlus | Detroit | 123 Main Street     | 48201   | Michigan | 001  |
      | MetPlus | Detroit | 456 Sullivan Street | 48204   | Michigan | 002  |
      | MetPlus | Detroit | 3 Auto Drive        | 48206   | Michigan | 003  |

    Given the following job categories exist:
      | name                      | description                         |
      | Software Engineer - RoR   | Develop website using Ruby on Rails |

    Given I am on the home page

  @allow-rescue
  Scenario:
    Given I login as "jane@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    And I go to the agency 'MetPlus' edit page
    And I should see "You are not authorized to edit MetPlus agency."