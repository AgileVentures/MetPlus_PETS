Feature: Reject a job application

  As a company person
  I want to reject a job application

  Background: data is added to database

    Given the default settings are present

    Given the following agency people exist:
      | agency  | role      | first_name | last_name | email                | password  |
      | MetPlus | JD        | Dave       | Smith     | dave@metplus.org     | qwerty123 |

    Given the following companies exist:
      | agency  | name         | website     | phone        | email          | job_email      | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email           | password  | phone        |
      | Widgets Inc. | CC    | Cicil      | Smith     | cicil@ymail.com | qwerty123 | 555-222-3334 |
      | Widgets Inc. | CA    | Cane       | Daniel    | cane@ymail.com  | qwerty123 | 555-222-3334 |

    Given the following jobseekers exist:
      | first_name | last_name | email         | phone        | password  | year_of_birth | job_seeker_status  |
      | John       | Seeker    | john@mail.com | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |
      | Jane       | Seeker    | jane@mail.com | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |
      | June       | Seeker    | june@mail.com | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |

    Given the following agency relations exist:
      | job_seeker    | agency_person    | role |
      | john@mail.com | dave@metplus.org | JD   |
      | june@mail.com | dave@metplus.org | JD   |

    Given the following jobs exist:
      | title        | company_job_id | description | company      | creator          |
      | hr manager   | KRK02K         | internship  | Widgets Inc. | cane@ymail.com |

    Given the following job applications exist:
      | job title    | job seeker    | status       |
      | hr manager   | john@mail.com | active       |
      | hr manager   | jane@mail.com | active       |
      | hr manager   | june@mail.com | active       |

  @javascript
  Scenario: company contact reject a job application
    Given I am on the home page
    And I login as "cicil@ymail.com" with password "qwerty123"
    And I wait 1 second
    Then I click the "hr manager" link
    And I should see "3" active applications for "hr manager"
    Then I reject "jane@mail.com" application for "hr manager"
    And I should see an "reject" confirmation
    And I click the "Reject" button
    And I should see "Please provide the reason for rejection"
    And I input "Skillset not matching" as the reason for rejection
    Then I click the "Reject" button
    And I should see "jane@mail.com" application is listed last
    And I should see "jane@mail.com" application for "hr manager" changes to not_accepted

  @email
  @javascript
  Scenario: job developer reject notification when job application rejected
    When I am in Job Developer's browser
    Given I am on the home page
    And I login as "dave@metplus.org" with password "qwerty123"

    When I am in Company Admin's browser
    Given I am on the home page
    And I login as "cane@ymail.com" with password "qwerty123"
    Then I click the "hr manager" link
    And I reject "john@mail.com" application for "hr manager"
    And I input "Not enough experience" as the reason for rejection
    And I click the "Reject" button
    And I wait for 2 seconds

    Then I am in Job Developer's browser
    And "dave@metplus.org" should receive an email with subject "Job application rejected"
    Then "dave@metplus.org" opens the email
    And I should see "A job application is rejected:" in the email body
    And I should see notification "Job Application: hr manager by John Seeker is rejected."
