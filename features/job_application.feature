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
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com   | qwerty123 | 555-222-3334 |
  | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com | qwerty123 | 555-222-3334 |

Given the following jobs exist:
  | title               | company_job_id  | description                 | company      | creator          |
  | software developer  | KRK01K          | internship position with pay| Widgets Inc. | carter@ymail.com |
  | editor              | T01KS           | This will be edited         | Widgets Inc. | jane@ymail.com   |

Given the following question records:
  | question_text                                         |
  | Are you authorized to work in the US?                 |
  | Are you willing to have a background check performed? |
  | Are you willing to take a drug test?                  |

Given the following job_question records:
  | job_id | question_id |
  | 2      | 1           |
  | 2      | 3           |

Given the following jobseekers exist:
  | first_name| last_name| email                     | phone       | password   |password_confirmation| year_of_birth |job_seeker_status |
  | John      | Seeker   | john.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |
  | Jane      | Seeker   | jane.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |

Given the following resumes exist:
  | file_name          | job_seeker             |
  | Janitor-Resume.doc | john.seeker@gmail.com |
  | Janitor-Resume.doc | jane.seeker@gmail.com |

Given the following agency relations exist:
  | job_seeker             | agency_person    | role |
  | john.seeker@gmail.com | jane@metplus.org | JD   |
  | john.seeker@gmail.com | mike@metplus.org | CM   |

Given the following job applications exist:
  | job title          | job seeker             |
  | software developer | jane.seeker@gmail.com |

  @javascript
  Scenario: Job seeker cannot apply to job
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
    And I login as "carter@ymail.com" with password "qwerty123"
    Then I should see "Signed in successfully."

    Then I am in Seeker's browser
    Given I am on the home page
    And I login as "john.seeker@gmail.com" with password "password"
    Then I should see "Signed in successfully"
    Then I click the "Jobs" link
    And I should see "software developer"
    Then I click the "software developer" link
    And I wait for 5 second
    Then I should not see "Click Here To Apply Online" 
    # And I wait for 1 second
    # And I should see "Job Application"
    # Then I press "Close"
    # Then I click the "Click Here To Apply Online" link
    # And I wait for 1 second
    # And I should see "Job Application"
    # Then I click the "Apply Now" button
    # And I wait 4 seconds
    # And I should see "Congratulations, you were able to apply with success"

    # Then "corp@ymail.com" should receive an email with subject "Job Application received"
    # When "corp@ymail.com" opens the email
    # Then they should see "you have received an application for the job" in the email body
    # And there should be an attachment named "Janitor-Resume.doc"
    # And attachment 1 should be of type "application/msword"

    # Then I am in Job Developer's browser
    # And I wait 1 second
    # And I should see "Job Seeker: John Seeker has applied to this job"
    # Then I am in Case Manager's browser
    # And I should see "Job Seeker: John Seeker has applied to this job"
    # Then I am in Company Admin's browser
    # And I should see "Job Seeker: John Seeker has applied to this job"

    # Then "jane@metplus.org" should receive an email with subject "Job seeker applied"
    # Then "mike@metplus.org" should receive an email with subject "Job seeker applied"
    # Then "carter@ymail.com" should receive an email with subject "Job seeker applied"
    # When "carter@ymail.com" opens the email
    # Then they should see "A job seeker has applied to this job:" in the email body
    # And "carter@ymail.com" follows "software developer" in the email
    # Then they should see "Widgets Inc."

    # Then I am in Company Admin's browser
    # And I am on the Company Person 'carter@ymail.com' Home page
    # And I wait 1 second
    # And I click the "Unassigned Tasks" link
    # And I should see "Review job application"
    # And I should see "Seeker, John has applied to: software developer"

  # Scenario: Job seeker cannot re-apply to the same job # not relevant now job seekers cannot apply for jobs personally
  #   Given I am on the home page
  #   And I login as "john.seeker@gmail.com" with password "password"
  #   Then I should see "Signed in successfully"
  #   Then I apply to "software developer" from Jobs link
  #   And I should see "Congratulations, you were able to apply with success"
  #   Then I click the "Jobs" link
  #   Then I click the "software developer" link
  #   And I should see "You already have an application submitted for this job."
  #   When I click the "edit your profile" link
  #   Then I should see "Update Your Profile"
  #   And The field 'Email' should have the value 'john.seeker@gmail.com'

  # Scenario: Company person should not be able to apply
  #   Given I am on the home page
  #   And I login as "carter@ymail.com" with password "qwerty123"
  #   Then I should see "Signed in successfully"
  #   Then I click the "Jobs" link
  #   And I should see "software developer"
  #   Then I click the "software developer" link
  #   Then I should not see "Click Here To Apply Online"

  # Scenario: Not logged in should not be able to apply
  #   Given I am on the home page
  #   Then I click the "Jobs" link
  #   And I should see "software developer"
  #   Then I click the "software developer" link
  #   Then I should not see "Click Here To Apply Online"

  @javascript
  Scenario: Download resume file_name as a Company Admin
    Given I am on the home page
    And I am logged in as "carter@ymail.com" with password "qwerty123"
    And I wait 1 second
    Then I click the "software developer" link
    And I wait 1 second
    And I should see "Applications for this Job"
    Then I click the "Seeker, Jane" link
    Then I should see button "Download Resume"
    And I click the "Download Resume" button

  # @javascript # not relevant now job seekers cannot apply for jobs personally
  # Scenario: Having applicant answer questions during the application process
  #   Then I am in Seeker's browser
  #   Given I am on the home page
  #   And I login as "john.seeker@gmail.com" with password "password"
  #   Then I should see "Signed in successfully"
  #   Then I click the "Jobs" link
  #   And I should see "editor"
  #   Then I click the "editor" link
  #   And I wait for 5 second
  #   Then I click the "Click Here To Apply Online" link
  #   And I wait for 1 second
  #   And I should see "Job Application"
  #   Then I press "Close"
  #   Then I click the "Click Here To Apply Online" link
  #   And I wait for 1 second
  #   And I should see "Job Application"
  #   And I should not see "Apply Now"
  #   And I answer first application question with Yes
  #   And I answer another application question with No
  #   Then I click the "Apply Now" button
  #   And I wait 4 seconds
  #   And I should see "Congratulations, you were able to apply with success"
