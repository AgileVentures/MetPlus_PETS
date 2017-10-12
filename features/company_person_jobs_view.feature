Feature: Company Person Jobs View

  As a company person
  I want to view all available job listings in my company

  Background:
    Given the following agencies exist:
      | name    | website     | phone        | email                  | fax          |
      | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

    Given the following company roles exist:
      | role  |
      | CA    |

    Given the following companies exist:
      | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com   | corp@ymail.com | 12-3456789 | active |
      | MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | corp@feature.com | 12-3456788 | active |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email            | password  | phone        |
      | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com | qwerty123 | 555-222-3334 |
      | Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |

    Given the following jobs exist:
      | title        | company_job_id  | description| company      | creator          |
      | software dev | KRK01K          | internship | Widgets Inc. | carter@ymail.com |
      | Cook         | KRK11K          | internship | Feature Inc. | ca@feature.com   |
      | Doctor       | AAEE1K          | internship | Feature Inc. | ca@feature.com   |

  @javascript
  Scenario: verify job listing in home page
    Given I am on the home page
    And I login as "ca@feature.com" with password "qwerty123"
    And I should be on the Company Person 'ca@feature.com' Home page
    And I wait for 5 seconds
    And I should see "Cook"
    And I should see "Doctor"
    And I should not see "software dev"
