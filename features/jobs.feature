Feature: Manage Jobs

As a company person or job developer
I want to create, update, and delete jobs

Background: adding job to database

	Given the default settings are present

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  | phone        |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 | 555-222-3334 |
  | MetPlus | JD    | Hugh       | Jobs      | hr@metplus.org   | qwerty123 | 555-222-3334 |

  Given the following companies exist:
  | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | active |
  | MetPlus | Gadgets Inc. | gadgets.com | 555-222-4444 | corp@gadgets.com | corp@gadgets.com | 12-3456791 | active |

  Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
  | title         | company_job_id  | shift  | fulltime | description | company      | creator          |
  | software dev  | KRK01K          | Evening| true     | internship  | Widgets Inc. | jane@widgets.com |

  Given the following company addresses exist:
  | company      | street       | city    | state    | zipcode |
  | Widgets Inc. | 10 Spring    | Detroit | Michigan | 02034   |
  | Widgets Inc. | 13 Summer    | Detroit | Michigan | 02054   |
  | Widgets Inc. | 16 Fall      | Detroit | Michigan | 02074   |
  | Widgets Inc. | 19 Winter    | Detroit | Michigan | 02094   |
  | Gadgets Inc. | 2 Ford Drive | Detroit | Michigan | 02094   |


@selenium
Scenario: Creating, Updating, and Deleting Job successfully and unsuccessfully
  Given I am on the home page
	And I login as "jane@widgets.com" with password "qwerty123"
	When I click the "Post jobs" link
	And I wait 1 second
	And I fill in the fields:
		| Title            | cashier|
		| Company Job ID   | KARK12 |
		| Description      | At least two years work experience|
	And I select "Day" in select list "Shift"
  And  I select "16 Fall Detroit, Michigan 02074" in select list "Job Location"
	And I check "Fulltime"
	And I press "new-job-submit"
	Then I should see "cashier has been created successfully."

	Then I click the first "edit" link
	And I fill in the fields:
		| Title                  | cab-driver|
		| Company Job ID         | KRT123    |
		| Description            | Atleast two years work experience|
	And  I select "Day" in select list "Shift"
  And  I select "19 Winter Detroit, Michigan 02094" in select list "Job Location"
	Then I check "Fulltime"
	And I press "Update"
	Then I should see "cab-driver has been updated successfully."
	And I should verify the change of title "cab-driver", shift "Day" and jobId "KRT123"

  Then I go to the Company Person 'jane@widgets.com' Home page
  And I click the "software dev" link
  And I click the "Edit Job" link
	And  I fill in the fields:
		| Title                  | cashier|
		| Company Job ID         |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "edit-job-submit"
	Then  I should see "The form contains 2 errors"

	When I click the "Post jobs" link
	And  I fill in the fields:
		| Title                  |  |
		| Company Job ID         |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "The form contains 3 errors"
	And I logout


@selenium
Scenario: Creating and Updating Job successfully and unsuccessfully
  Given I am on the home page
	And I login as "hr@metplus.org" with password "qwerty123"
	When I click the "Post jobs" link
	And I wait 1 second
	And I fill in the fields:
		| Title                  | cashier|
	And  I select "Widgets Inc." in select list "Company Name"
	And  I select "13 Summer Detroit, Michigan 02054" in select list "Job Location"
	And I fill in the fields:
		| Company Job ID         | KARK12 |
		| Description            | At least two years work experience|
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then I should see "cashier has been created successfully."

  Then I click the "Jobs" link
  And I click the "software dev" link
  And I click the "Edit Job" link
  And  I select "Gadgets Inc." in select list "Company Name"
	And  I select "2 Ford Drive Detroit, Michigan 02094" in select list "Job Location"
  And  I press "edit-job-submit"
  Then  I should see "software dev has been updated successfully."

  Then I click the "Jobs" link
  And I click the "cashier" link
  And I click the "Edit Job" link
	And  I fill in the fields:
		| Title                  | cashier|
		| Company Job ID         |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "edit-job-submit"
	Then  I should see "The form contains 2 errors"

	When I click the "Post jobs" link
	And  I fill in the fields:
		| Title                  |  |
	And  I select "Widgets Inc." in select list "Company Name"
	And I select "19 Winter Detroit, Michigan 02094" in select list "Job Location"
	And I fill in the fields:
		| Company Job ID         |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "The form contains 3 errors"

@javascript
Scenario: Cancel out of job edit
  Given I am on the home page
	And I login as "jane@widgets.com" with password "qwerty123"
  Then I should be on the Company Person 'jane@widgets.com' Home page
  And I click the "software dev" link
  And I wait 1 second
  And I should see "Revoke"
  And I click the "Edit Job" link
  And I should see "Edit Job"
  And I wait 1 second
  And I should not see "Revoke"
  And I click the "Cancel" link
  And I wait 1 second
  And I should see "Revoke"
