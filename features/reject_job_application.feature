Feature: Reject a job application

  As a company person
  I want to reject a job application

  Background: data is added to database

    Given the default settings are present

    Given the following agency people exist:
      | agency  | role      | first_name | last_name | email                | password  |
      | MetPlus | JD        | Dave       | Smith     | dave@metplus.org     | qwerty123 |

    Given the following companies exist:
      | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | active |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email            | password  | phone        |
      | Widgets Inc. | CC    | Cicil      | Smith     | cicil@widgets.com | qwerty123 | 555-222-3334 |
      | Widgets Inc. | CA    | Cane       | Daniel    | cane@widgets.com | qwerty123 | 555-222-3334 |

    Given the following jobseeker exist:
      | first_name | last_name | email         | phone        | password  | password_confirmation | year_of_birth | job_seeker_status  |
      | John       | Seeker    | john@seek.com | 345-890-7890 | qwerty123 | qwerty123             | 1990          | Unemployed Seeking |
      | Jane       | Seeker    | jane@seek.com | 345-890-7890 | qwerty123 | qwerty123             | 1990          | Unemployed Seeking |
      | June       | Seeker    | june@seek.com | 345-890-7890 | qwerty123 | qwerty123             | 1990          | Unemployed Seeking |

    Given the following agency relations exist:
      | job_seeker    | agency_person    | role |
      | john@seek.com | dave@metplus.org | JD   |
      | june@seek.com | dave@metplus.org | JD   |

    Given the following jobs exist:
      | title        | company_job_id | shift | fulltime | description | company      | creator          |
      | hr manager   | KRK02K         | Day   | true     | internship  | Widgets Inc. | cane@widgets.com |

    Given the following job applications exist:
      | job title 	 | job seeker 	 | status 			|
      | hr manager	 | john@seek.com | active 			|
      | hr manager	 | jane@seek.com | active 			|
      | hr manager	 | june@seek.com | active 			|

  @javascript
  Scenario: company contact reject a job application
    Given I am on the home page
    And I login as "cicil@widgets.com" with password "qwerty123"
    And I wait 1 second
    Then I click "hr manager" link to job applications index page
    And I should see "3" active applications for the job
    Then I reject "jane@seek.com" application
    And I should see an "reject" confirmation
    And I input "Skillset not matching" as the reason for rejection
    Then I click the "Reject" button
    And I should see "jane@seek.com" application is listed last
    And I should see "jane@seek.com" application changes to not_accepted

  @javascript
  Scenario: company admin reject a job application
    Given I am on the home page
    And I login as "cane@widgets.com" with password "qwerty123"
    And I wait 1 second
    Then I click "hr manager" link to job applications index page
    And I should see "3" active applications for the job
    Then I click "june@seek.com" link to "June's" job application show page
    Then I click the "Reject" link
    And I should see an "reject" confirmation
    And I input "Skillset not matching" as the reason for rejection
    Then I click the "Reject" button
    And I am returned to "hr manager" job application index page
    And I should see "june@seek.com" application is listed last
    And I should see "june@seek.com" application changes to not_accepted
    Then I click "june@seek.com" link to "June's" job application show page
    And I should not see "Reject" link

  @selenium
  Scenario: job developer reject notification when job application rejected
    When I am in Job Developer's browser
    Given I am on the home page
    And I login as "dave@metplus.org" with password "qwerty123"

    When I am in Company Admin's browser
    Given I am on the home page
    And I login as "cane@widgets.com" with password "qwerty123"
    Then I click "hr manager" link to job applications index page
    And I reject "john@seek.com" application
    And I input "Not enough experience" as the reason for rejection
    And I click the "Reject" button
    And I wait for 2 seconds

    Then I am in Job Developer's browser
    And "dave@metplus.org" should receive an email with subject "Job application rejected"
    Then "dave@metplus.org" opens the email
    And I should see "A job application is rejected:" in the email body


