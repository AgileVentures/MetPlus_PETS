Feature: Apply to a job

As a job seeker
I want to apply to a job

Background: adding job to database
Given the default settings are present

Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | JD    | Jane       | Jones     | jane@metplus.org | qwerty123 |
  | MetPlus | CM    | Mike       | Manager   | mike@metplus.org | qwerty123 |


Given the following companies exist:
  | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | active |

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

Given the following resumes exist:
  | file_name          | job_seeker             |
  | Janitor-Resume.doc | john.seeker@places.com |

Given the following agency relations exist:
  | job_seeker             | agency_person    | role |
  | john.seeker@places.com | jane@metplus.org | JD   |
  | john.seeker@places.com | mike@metplus.org | CM   |

  @selenium
  Scenario: Job seeker applies to job
    When I am in Job Developer's browser
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"
    And I wait 2 seconds
    Then I should see "Signed in successfully."

    When I am in Case Manager's browser
    Given I am on the home page
    And I login as "mike@metplus.org" with password "qwerty123"
    Then I should see "Signed in successfully."

    When I am in Company Admin's browser
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    Then I should see "Signed in successfully."

    Then I am in Seeker's browser
    Given I am on the home page
    And I login as "john.seeker@places.com" with password "password"
    Then I should see "Signed in successfully"
    Then I click the "Jobs" link
    And I should see "software developer"
    Then I click the "software developer" link
    And I wait for 5 second
    Then I click the "Click Here To Apply Online" link
    And I wait for 1 second
    And I should see "Application process"
    Then I press "Close"
    Then I click the "Click Here To Apply Online" link
    And I wait for 1 second
    And I should see "Application process"
    Then I click the "Apply Now" link
    And I wait 2 seconds
    And I should see "Congratulations, you were able to apply with success"

    Then "corp@widgets.com" should receive an email with subject "Job Application received"
    When "corp@widgets.com" opens the email
    Then they should see "you have received an application for the job" in the email body
    And there should be an attachment named "Janitor-Resume.doc"
    And attachment 1 should be of type "application/msword"

    Then I am in Job Developer's browser
    And I wait 1 second
    And I should see "Job Seeker: John Seeker has applied to this job"
    Then I am in Case Manager's browser
    And I should see "Job Seeker: John Seeker has applied to this job"
    Then I am in Company Admin's browser
    And I should see "Job Seeker: John Seeker has applied to this job"

    Then "jane@metplus.org" should receive an email with subject "Job seeker applied"
    Then "mike@metplus.org" should receive an email with subject "Job seeker applied"
    Then "ca@widgets.com" should receive an email with subject "Job seeker applied"
    When "ca@widgets.com" opens the email
    Then they should see "A job seeker has applied to this job:" in the email body
    And "ca@widgets.com" follows "software developer" in the email
    Then they should see "Widgets Inc."

    Then I am in Company Admin's browser
    And I am on the Company Person 'ca@widgets.com' Home page
    And I should see "Review job application"
    And I should see "Job: software developer"

  Scenario: Job seeker cannot re-apply to the same job
    Given I am on the home page
    And I login as "john.seeker@places.com" with password "password"
    Then I should see "Signed in successfully"
    Then I apply to "software developer" from Jobs link
    And I should see "Congratulations, you were able to apply with success"
    Then I click the "Jobs" link
    Then I click the "software developer" link
    And I should see "You already have an application submitted for this job."

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

  @javascript
  Scenario: Download resume file_name as a Company Admin
    Given I am on the home page
    And I am logged in as "ca@widgets.com" with password "qwerty123"
    And I should see "software developer"
    When I click the "1" link
    And I wait 1 second
    And I should see "Applications for this Job"
    Then I click the "Seeker, John" link
    Then I should see button "Download Resume"
    And I click the "Download Resume" button
    Then I should get a download with the filename "Janitor-Resume.doc"
