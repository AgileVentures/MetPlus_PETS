Feature: Apply to a job

As a job seeker
I want to apply to a job

Background: adding job to database
Given the default settings are present

Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | JD    | Jane       | Jones     | jane@metplus.org | qwerty123 |


Given the following companies exist:
  | agency  | name         | website     | phone        | email            | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |

Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
  | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |

Given the following jobs exist:
  | title               | company_job_id  | shift  | fulltime | description                 | company      | creator        |
  | software developer  | KRK01K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |

Given the following jobseeker exist:
  | first_name| last_name| email                     | phone       | password   |password_confirmation| year_of_birth |job_seeker_status |
  | John      | Seeker   | john.seeker@places.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |

  @selenium
  Scenario: Job seeker applies to job
    Given I am on the home page
    And I login as "john.seeker@places.com" with password "password"
    Then I should see "Signed in successfully"
    Then I click the "Jobs" link
    And I should see "software developer"
    Then I click the "software developer" link
    Then I click the "Click Here To Apply Online" link
    And I wait for 1 second
    And I should see "Application process"
    Then I press "Close"
    Then I click the "Click Here To Apply Online" link
    And I wait for 1 second
    And I should see "Application process"
    Then I click the "Apply Now" link
    And I should see "Congratulations, you were able to apply with success"

  Scenario: Company person should not be able to apply
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    Then I should see "Signed in successfully"
    Then I click the "Jobs" link
    And I should see "software developer"
    Then I click the "software developer" link
    Then I should not see "Click Here To Apply Online"


  Scenario: Not logged in should not be able to apply
    Given I am on the home page
    Then I click the "Jobs" link
    And I should see "software developer"
    Then I click the "software developer" link
    Then I should not see "Click Here To Apply Online"
