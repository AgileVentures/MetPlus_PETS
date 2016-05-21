Feature: Manage Jobs

As a company person or job developer
I want to create, update, and delete jobs

Background: adding job to database

	Given the following agency roles exist:
		| role  |
		| AA    |
		| CM    |
		| JD    |

@selenium
Scenario: Creating, Updating, and Deleting Job successfully and unsuccessfully
	Given I am logged in as company person
	When I click the "Post jobs" link
	And I wait 1 second
	And I fill in the fields:
		| Title                  | cashier|
		| Job id                 | KARK12 |
		| Description            | At least two years work experience|
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then I should see "cashier has been created successfully."

	When I click the "jobs-edit-link" link
	And I fill in the fields:
		| Title                  | cab-driver|
		| Job id                 | KRT123 |
		| Description            | Atleast two years work experience|
	And  I select "Day" in select list "Shift"
	Then I check "Fulltime"
	And I press "Update"
	Then I should see "cab-driver has been updated successfully."
	And I should verify the change of title "cab-driver", shift "Day" and jobId "KRT123"

	When I click the "Return To Jobs" link
	And I click the "delete" button
	And I wait 1 second
	Then I should see a popup with the following job information
	And I wait 1 second
	And I click the "modal-delete-id" link
	And I wait 2 seconds
	Then I should see "cab-driver has been deleted successfully."

	And I am on the Job edit page with given record:
	And  I fill in the fields:
		| Title                  | cashier|
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "edit-job-submit"
	Then  I should see "The form contains 2 errors"

	When I click the "Post jobs" link
	And  I fill in the fields:
		| Title                  |  |
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "The form contains 3 errors"
	And I logout


@selenium
Scenario: Creating, Updating, and Deleting Job successfully and unsuccessfully
	Given I am logged in as job developer
	And the Widgets, Inc. company name with address exist in the record
	When I click the "Post jobs" link
	And I wait 1 second
	And I fill in the fields:
		| Title                  | cashier|
	And  I select "Widgets, Inc." in select list "Company Name"
	And  I select "3940 Main Street Detroit, Michigan 92105" in select list "Company Address"
	And I fill in the fields:
		| Job id                 | KARK12 |
		| Description            | Atleast two years work experience|
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then I should see "cashier has been created successfully."


	And I am on the Job edit page with given record:
	And  I fill in the fields:
		| Title                  | cashier|
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "edit-job-submit"
	Then  I should see "The form contains 2 errors"

	When I click the "Post jobs" link
	And  I fill in the fields:
		| Title                  |  |
	And  I select "Widgets, Inc." in select list "Company Name"
	And I select "3940 Main Street Detroit, Michigan 92105" in select list "Company Address"
	And I fill in the fields:
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "The form contains 3 errors"
