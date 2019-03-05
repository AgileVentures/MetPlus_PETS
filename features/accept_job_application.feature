Feature: Accept a job application

  As a company person
  I want to accept a job application

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
    | first_name | last_name | email         | phone         | password  | year_of_birth | job_seeker_status  |
    | John       | Seeker    | john@ymail.com | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |
    | Jane       | Seeker    | jane@ymail.com | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |
    | June       | Seeker    | june@ymail.com | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |

  Given the following agency relations exist:
    | job_seeker     | agency_person    | role |
    | john@ymail.com | dave@metplus.org | JD   |
    | june@ymail.com | dave@metplus.org | JD   |

  Given the following jobs exist:
    | title        | company_job_id | description | company      | creator          |
    | hr manager   | KRK02K         | internship  | Widgets Inc. | cane@ymail.com |
    | hr assistant | KRK01K         | internship  | Widgets Inc. | cane@ymail.com |

  Given the following job applications exist:
    | job title      | job seeker    | status       |
    | hr manager     | john@ymail.com | active       |
    | hr manager     | jane@ymail.com | active       |
    | hr manager     | june@ymail.com | active       |
    | hr assistant   | june@ymail.com | active       |
  @javascript
  Scenario: company contact accept a job application
    Given I am on the home page
    And I login as "cicil@ymail.com" with password "qwerty123"
    And I wait 1 second
    Then I click the "hr manager" link
    And I should see "3" active applications for "hr manager"
    Then I accept "jane@ymail.com" application for "hr manager"
    And I should see an "accept" confirmation
    Then I click the "Accept" confirmation
    And I wait 1 second
    And I should see "jane@ymail.com" application for "hr manager" changes to accepted
    And I should see "jane@ymail.com" application is listed first
    And other applications for "hr manager" change to not accepted
    And I should see "hr manager" job changes to status filled

  @javascript
  Scenario: company admin accept a job application
    Given I am on the home page
    And I login as "cane@ymail.com" with password "qwerty123"
    And I wait 1 second
    Then I click the "hr manager" link
    And I should see "3" active applications for "hr manager"
    Then I click the "Seeker, June" link
    And I should see "2" active applications by "june@ymail.com"
    Then I accept "june@ymail.com" application for "hr assistant"
    And I should see an "accept" confirmation
    Then I click the "Accept" confirmation
    And I should see "june@ymail.com" application is listed first
    And I should see "june@ymail.com" application for "hr assistant" changes to accepted
    And other applications for "hr assistant" change to not accepted
    And I should see "hr assistant" job changes to status filled

  @javascript
  @email
  Scenario: job developer accept notification when job application accepted
    When I am in Job Developer's browser
    Given I am on the home page
    And I login as "dave@metplus.org" with password "qwerty123"

    When I am in Company Admin's browser
    Given I am on the home page
    And I login as "cane@ymail.com" with password "qwerty123"
    Then I click the "hr manager" link
    And I accept "john@ymail.com" application for "hr manager"
    And I click the "Accept" confirmation

    Then I am in Job Developer's browser
    And I should see "Job Application: hr manager by John Seeker is accepted"
    And "dave@metplus.org" should receive an email with subject "Job application accepted"
    Then "dave@metplus.org" opens the email
    And I should see "A job application is accepted:" in the email body
