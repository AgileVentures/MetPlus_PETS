Feature: Job developer submit application for his job seeker

As a job developer
I want to apply to a job for my job seeker

Background: data is added to database

  Given the default settings are present

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | JD,CM | Jane       | Jones     | jane@metplus.org | qwerty123 |
  | MetPlus | JD    | John       | Happy     | john@metplus.org | qwerty123 |

  Given the following companies exist:
  | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

  Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com   | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
  | title               | company_job_id  | description                 | company      | creator        |
  | software developer  | KRK01K          | internship position with pay| Widgets Inc. | carter@ymail.com |

  Given the following jobseekers exist:
  | first_name| last_name| email                     | phone       | password   |password_confirmation| year_of_birth |job_seeker_status |
  | John      | Seeker   | john.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |
  | Jane      | Seeker   | jane.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |
  | June      | Seeker   | june.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |
  | July      | Seeker   | july.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |

  Given the following resumes exist:
  | file_name          | job_seeker             |
  | Janitor-Resume.doc | john.seeker@gmail.com |

  Given the following agency relations exist:
  | job_seeker             | agency_person    | role |
  | john.seeker@gmail.com | jane@metplus.org | JD   |
  | june.seeker@gmail.com | jane@metplus.org | JD   |
  | july.seeker@gmail.com | jane@metplus.org | CM   |

  @email
  @javascript
  Scenario: Successful application for his job seeker
    When I am in Company Admin's browser
    Given I am on the home page
    And I login as "carter@ymail.com" with password "qwerty123"

    When I am in Job Seeker's browser
    Given I am on the home page
    And I login as "john.seeker@gmail.com" with password "password"

    Then I am in Job Developer's browser
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"
    Then I apply to "software developer" for my job seeker: "Seeker, John"
    And I should see "Job is successfully applied for Seeker, John"

    Then I am in Job Seeker's browser
    And I should see "Your job developer has applied to this job for you"
    Then "john.seeker@gmail.com" should receive an email with subject "Job applied by job developer"
    When "john.seeker@gmail.com" opens the email
    Then they should see "your job developer," in the email body
    Then they should see "Jane Jones" in the email body
    Then they should see "has submitted an application on your behalf to the job:" in the email body
    Then they should see "software developer" in the email body
    Then they should see "in company: Widgets Inc." in the email body

    Then I am in Company Admin's browser
    And I should see "Job Seeker: John Seeker has applied to this job"
    And I am on the Company Person 'carter@ymail.com' Home page
    And I wait 1 second
    And I click the "Unassigned Tasks" link
    And I should see "Review job application"
    And I should see "Seeker, John has applied to: software developer"
    Then "carter@ymail.com" should receive an email with subject "Job seeker applied"
    When "carter@ymail.com" opens the email
    Then they should see "A job seeker has applied to this job:" in the email body
    And "carter@ymail.com" follows "software developer" in the email
    Then they should see "Widgets Inc."

  Scenario: job developer not logged in
    Given I am on the home page
    And I visit the jobs page
    Then I click the "software developer" link
    And I should not see "Click Here to Submit an Application for Job Seeker"

  @javascript
  Scenario: job developer cannot apply for his job seeker with CM role
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"
    And I wait 1 second
    Then I want to apply to "software developer" for "Seeker, July"
    But I cannot find "Seeker, July" from my job seekers list

  @javascript
  Scenario: job developer cannot apply for his job seeker without resume
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"

    Then I want to apply to "software developer" for "Seeker, June"
    Then I find "Seeker, June" from my job seekers list and proceed with the application
    And I should see "* Job Seeker cannot be empty"

  # @javascript # not relevant now job seekers cannot apply for jobs personally
  # Scenario: Job developer cannot re-apply to the same job when the job has been applied by job seeker
  #   When I am in Job Seeker's browser
  #   Given I am on the home page
  #   And I login as "john.seeker@gmail.com" with password "password"
  #   Then I apply to "software developer" from Jobs link
  #   And I wait 4 seconds
  #   And I should see "Congratulations, you were able to apply with success"

  #   Then I am in Job Developer's browser
  #   Given I am on the home page
  #   And I login as "jane@metplus.org" with password "qwerty123"
  #   Then I apply to "software developer" for my job seeker: "Seeker, John"
  #   And I should see "John Seeker has already applied to this job"

  @javascript
  Scenario: Job developer cannot apply for his job seeker without consent given
    When I am in Job Seeker's browser
    Given I am on the home page
    And I login as "john.seeker@gmail.com" with password "password"
    Then I click the "Hello, John" link
    And I click the "My Profile" link
    Then I click the "Edit" link
    Then I update my profile to not permit job developer to apply a job for me

    Then I am in Job Developer's browser
    Given I am on the home page
    Then I login as "jane@metplus.org" with password "qwerty123"
    Then I want to apply to "software developer" for "Seeker, John"
    But I cannot find "Seeker, John" from my job seekers list

# Commented this test because currently there is no way
# to apply for a js that the JD is not the assigned one
#  @javascript
#  Scenario: Apply for a Job Seeker that I am not the assigned Job Developer
#    When I am in Assigned Job Developer's browser
#    Given I am on the home page
#    And I login as "john@metplus.org" with password "qwerty123"
#
#    Then I am in Job Developer's browser
#    Given I am on the home page
#    And I login as "john@metplus.org" with password "qwerty123"
#    Then I apply to "software developer" for my job seeker: "Seeker, John"
#    And I should see "Job is successfully applied for Seeker, John"
#
#    Then "jane@metplus.org" should receive an email with subject "Job applied by other job developer"
#    When "jane@metplus.org" opens the email
#    Then they should see "Jane Jones" in the email body
#    Then they should see "has submitted an application on behalf of Seeker, John to the job:" in the email body
#    Then they should see "software developer" in the email body
#    Then they should see "in company: Widgets Inc." in the email body
