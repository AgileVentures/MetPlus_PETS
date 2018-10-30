Feature: Enable job developers to access the menu "Admin > Job Properties"

  As a job developer
  So that I can ....
  I would like to be able to access the job properties to ...

  Background: a job developer has been created and is logged in

    Given the following agency roles exist:
      | role |
      | JD   |
      | CM   |

    Given the following agencies exist:
      | name    | website     | phone        | email                  | fax          |
      | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

    Given the following agency people exist:
      | agency  | role | first_name | last_name | email          | password  |
      | MetPlus | JD   | Tom        | Smith     | jd@metplus.org | qwerty123 |

    Given I am on the home page

  Scenario:
    Given I login as "jd@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."
    And I should see "Admin"
    And I click the "Admin" link
    Then I should see "Job Properties"
    Then I should not see "Agency and Partner Companies"
    And I click the "Job Properties" link
    Then I should be on the agency admin job properties page


    # I'm in UR code dude
