Feature: Job developer submit application for his job seeker

As a job developer
I want to apply to a job for my job seeker

Background: data is added to database 

	Given the default settings are present

	Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | JD,CM | Jane       | Jones     | jane@metplus.org | qwerty123 |
	
	Given the following companies exist:
  | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | Active |

  Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
  | title               | company_job_id  | shift  | fulltime | description                 | company      | creator        |
  | software developer  | KRK01K          | Evening| true     | internship position with pay| Widgets Inc. | ca@widgets.com |

	Given the following jobseeker exist:
  | first_name| last_name| email                     | phone       | password   |password_confirmation| year_of_birth |job_seeker_status |
  | John      | Seeker   | john.seeker@places.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |
  | Jane      | Seeker   | jane.seeker@places.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |
  | June      | Seeker   | june.seeker@places.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |
  | July      | Seeker   | july.seeker@places.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |

  Given the following resumes exist:
  | file_name          | job_seeker             |
  | Janitor-Resume.doc | john.seeker@places.com |

	Given the following agency relations exist:
	| job_seeker             | agency_person    | role |
	| john.seeker@places.com | jane@metplus.org | JD   |
	| june.seeker@places.com | jane@metplus.org | JD   |
	| july.seeker@places.com | jane@metplus.org | CM   |

	@selenium
	Scenario: Successful application for his job seeker
		When I am in Company Admin's browser
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"

    When I am in Job Seeker's browser
    Given I am on the home page
    And I login as "john.seeker@places.com" with password "password"

  	Then I am in Job Developer's browser
	  Given I am on the home page
	  And I login as "jane@metplus.org" with password "qwerty123"

		Then I visit the jobs page
		Then I click the "software developer" link
		Then I click the "Click Here to Submit an Application for Job Seeker" link
    And I should see "Select your job seeker for the above job:"
    Then I select2 "Seeker, John" from "jd_apply_job_select"
    Then I press "Proceed"
    And I wait 1 second
    And I should see "John Seeker"
    Then I press "Apply Now"
    And I should see "Job is successfully applied for Seeker, John"

    Then I am in Job Seeker's browser
    And I should see "Your job developer has applied to this job for you"
    Then "john.seeker@places.com" should receive an email with subject "Job applied by job developer"
    When "john.seeker@places.com" opens the email
    Then they should see "your job developer," in the email body
    Then they should see "Jane Jones" in the email body
    Then they should see "has submitted an application on your behalf to the job:" in the email body
    Then they should see "software developer" in the email body
    Then they should see "in company: Widgets Inc." in the email body

    Then I am in Company Admin's browser
    And I should see "Job Seeker: John Seeker has applied to this job"
    And I am on the Company Person 'ca@widgets.com' Home page
    And I should see "Review job application"
    And I should see "Job: software developer"
    Then "ca@widgets.com" should receive an email with subject "Job seeker applied"
    When "ca@widgets.com" opens the email
    Then they should see "A job seeker has applied to this job:" in the email body
    And "ca@widgets.com" follows "software developer" in the email
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

    Then I visit the jobs page
    Then I click the "software developer" link
    Then I click the "Click Here to Submit an Application for Job Seeker" link
    Then I cannot select2 "Seeker, July" from "jd_apply_job_select"

  @javascript
  Scenario: job developer cannot apply for his job seeker without resume
    Given I am on the home page
    And I login as "jane@metplus.org" with password "qwerty123"

    Then I visit the jobs page
    Then I click the "software developer" link
    Then I click the "Click Here to Submit an Application for Job Seeker" link
    And I wait 1 second
    Then I select2 "Seeker, June" from "jd_apply_job_select"
    Then I press "Proceed"
    And I should see "* Job Seeker cannot be empty"
    


		

