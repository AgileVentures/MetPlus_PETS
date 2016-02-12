Feature: Manage Jobs  

As a user #not quite correct  
I want to post, edit, delete jobs 

background: adding job to database 
	Given the following jobs records:
	| title               | jobId   | shift  | fulltime | description | 
	| software developer  | KRK12K  | evening| true     | internship position with pay| 
Scenario: Creating and Updating Job successfully	
	Given I am on the job creation page 
    And  I fill in the fields: 
		| Title                  | cashier|  
		| Job id                 | KARK12 |  
		| Description            | Atleast two years work experience|  
	And  I select "day" in select list "Shift"
	And  I check  "job_fulltime" 
	And  I press "new-job-submit"
	Then  I should see "cashier has been created successfully." 

	When I click the "jobs-edit-link" link 
    And  I fill in the fields: 
		| Title                  | cab-driver|  
		| Job id                 | KRT123 |  
		| Description            | Atleast two years work experience|  
	And  I select "day" in select list "Shift"
	Then I check  "Fulltime" 
	And   I press "Update"
	Then  I should see "cab-driver has been updated successfully."
	And   I should verify the change of title "cab-driver", shift "day" and jobId "KRT123"

Scenario: Creating job unsuccessfully 
	Given I am on the job creation page
	And  I fill in the fields: 
		| Title                  | cashier|  
		| Job id                 |  |  
		| Description            |  |  
	And  I select "day" in select list "Shift"
	And  I check  "job_fulltime" 
	And  I press "new-job-submit"
	Then  I should see "The form contains 2 errors"

