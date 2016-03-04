Feature: Manage Jobs

As a user #not quite correct,
I want to create, update, and delete jobs

background: adding job to database
	Given the following jobs records:
	| title               | company_job_id  | shift  | fulltime | description |
	| software developer  | KRK12K  | evening| true     | internship position with pay|

@javascript
Scenario: Creating, Updating, and Deleting Job successfully
	Given I am on the job creation page
	And I wait 1 second
	And  I fill in the fields:
		| Title                  | cashier|
		| Job id                 | KARK12 |
		| Description            | Atleast two years work experience|
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "cashier has been created successfully."

	When I click the "jobs-edit-link" link
	And  I fill in the fields:
		| Title                  | cab-driver|
		| Job id                 | KRT123 |
		| Description            | Atleast two years work experience|
	And  I select "Day" in select list "Shift"
	Then I check "Fulltime"
	And   I press "Update"
	Then  I should see "cab-driver has been updated successfully."
	And   I should verify the change of title "cab-driver", shift "Day" and jobId "KRT123"

	When I click the "Return To Jobs" link
	And I click the "delete" button
	And I wait 1 second
	Then I should see a popup with the following job information
	And I wait 1 second
	And I click the "modal-delete-id" link
	And I wait 2 seconds
	Then I should see "cab-driver has been deleted successfully."

Scenario: Updating job unsuccessfully
	Given I am on the Job edit page with given record:
	And  I fill in the fields:
		| Title                  | cashier|
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "edit-job-submit"
	Then  I should see "The form contains 2 errors"

Scenario: Creating job unsuccessfully
	Given I am on the job creation page
	And  I fill in the fields:
		| Title                  |  |
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "The form contains 3 errors"
