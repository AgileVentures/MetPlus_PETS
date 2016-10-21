Feature: Manage job status by UI

	As a job developer / company person
	So that there is no job application on expired job
	I want to inform other job developer about a job status

Background: data is added to database

	Given the default settings are present

	Given the following agency people exist:
    | agency  | role      | first_name | last_name | email                | password  |
    | MetPlus | JD        | John       | Smith     | john@metplus.org     | qwerty123 |
    | MetPlus | CM        | Jane       | Jones     | jane@metplus.org     | qwerty123 |

  Given the following companies exist:
  	| agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  	| MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | active |
  	| MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | corp@feature.com | 12-3456788 | active |

  Given the following company people exist:
  	| company      | role  | first_name | last_name | email            | password  | phone        |
  	| Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
  	| Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |
  	| Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |

  Given the following jobseeker exist:
  	| first_name | last_name | email         | phone        | password  | password_confirmation | year_of_birth | job_seeker_status  |
  	| John       | Seeker    | john@mail.com | 345-890-7890 | qwerty123 | qwerty123             | 1990          | Unemployed Seeking |

  Given the following jobs exist:
    | title        | company_job_id | shift | fulltime | description | company      | creator        | status  |
    | hr assistant | KRK01K         | Day		| true     | internship  | Widgets Inc. | ca@widgets.com | revoked |
    | hr manager   | KRK02K         | Day   | true     | internship  | Widgets Inc. | ca@widgets.com | active  |
    | hr associate | KRK03K         | Day   | true     | internship  | Widgets Inc. | ca@widgets.com | active  |

  @selenium
	Scenario: company person revoke a job
		Given I am on the home page
	  And I login as "ca@widgets.com" with password "qwerty123"
	  And I visit the jobs page
	  And I should not see "Revoked" next to "hr manager"
	  But I should see "revoke" button for "hr manager"
	  Then I click the "revoke" button for "hr manager"
	  And I wait 1 second
	  And I should see a "revoke" confirmation
	  Then I click the Revoke confirmation for "hr manager"
	  And I should see "Revoked" next to "hr manager"

	@selenium
	Scenario: job developer revoke a job
		Given I am on the home page
		And I login as "john@metplus.org" with password "qwerty123"
	  And I visit the jobs page
	  And I should see "Revoked" next to "hr assistant"
	  Then I click the "hr assistant" link to job show page
	  And I wait 1 second
	  And I should see the job status is "revoked"
	  And I should not see "Revoke" link on the page
 	  Then I return to jobs page
 	  And I wait 1 second
 	  And I should not see "Revoked" next to "hr associate"
	  Then I click the "hr associate" link to job show page
	  And I should see the job status is "active"
	  And I should see "Revoke" link on the page
	  Then I click the "Revoke" link
	  And I wait 1 second
		And I should see a "revoke" confirmation
	  Then I click the Revoke confirmation for "hr associate"
	  And I should see "Revoked" next to "hr associate"

	Scenario: job seeker view job listed
		Given I am on the home page
		And I login as "john@mail.com" with password "qwerty123"
		And I visit the jobs page
	  And I should see "Revoked" next to "hr assistant"
	  Then I click the "hr assistant" link to job show page
	  And I should see the job status is "revoked"
	  And I should not see "Click Here To Apply Online"
	  Then I return to jobs page
	  And I should not see "Revoked" next to "hr manager"
	  Then I click the "hr manager" link to job show page
	  And I should see the job status is "active"
	  And I should see "Click Here To Apply Online"
