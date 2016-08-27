Feature: Apply to a job

As a job developer
I want to apply a job for my job seeker

Background: data is added to database 

	Given the default settings are present

	Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | JD,CM | Jane       | Jones     | jane@metplus.org | qwerty123 |
  | MetPlus | CM    | Mike       | Manager   | mike@metplus.org | qwerty123 |
	
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

	Given the following agency relations exist:
	| job_seeker             | agency_person    | role |
	| john.seeker@places.com | jane@metplus.org | JD   |
	| june.seeker@places.com | jane@metplus.org | JD   |
	| july.seeker@places.com | jane@metplus.org | CM   |
	| john.seeker@places.com | mike@metplus.org | CM   |

	@selenium
	Scenario: Job developer apply for his job seeker
		When I am in Company Admin's browser
    Given I am on the home page
    And I login as "ca@widgets.com" with password "qwerty123"
    Then I should see "Signed in successfully."

    When I am in Job Seeker's browser
    Given I am on the home page
    And I login as "john.seeker@places.com" with password "password"
    Then I should see "Signed in successfully"

  	Then I am in Job Developer's browser
	  Given I am on the home page
	  And I login as "jane@metplus.org" with password "qwerty123"
	  Then I should see "Signed in successfully."

		Then I visit the jobs page
		Then I click the "software developer" link
		Then I click the "Click Here to Submit an Application for Job Seeker" link
    And I should see "Select your job seeker for the above job:"
    And I wait 1 second
    Then I select2 "Seeker, John" from "jd_apply_job_select"
    Then I press "Proceed"
    And I wait 1 second
    And I should see "John Seeker"
    Then I press "Apply Now"
    And I wait 1 second
    And I should see "Job is successfully applied for Seeker, John"

    Then I am in Job Seeker's browser
    And I should see "Your job developer has applied this job for you"
    Then "john.seeker@places.com" should receive an email with subject "Job applied by job developer"
    When "john.seeker@places.com" opens the email
    Then they should see "your job developer," in the email body
    Then they should see "Jane Jones" in the email body
    Then they should see "has applied for you the job:" in the email body
    Then they should see "software developer" in the email body
    Then they should see ", in company: Widgets Inc." in the email body

    Then I am in Company Admin's browser
    And I am on the Company Person 'ca@widgets.com' Home page
    And I should see "Review job application"
    And I should see "Job: software developer"

		

