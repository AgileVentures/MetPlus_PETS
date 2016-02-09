Feature: Manage Jobs  

As a user #not quite correct  
I want to post, edit, delete jobs 

background: job has been added to database 
	Given the following job records:
	| title               | jobId   | shift  | fulltime | description | 
	| software developer  | KRK12K  | evening| true     | internship position with pay| 

Scenario: Updating Job successfully	
	Given I am on the jobs page 	
	Then I click the "edit" button 
    And  I fill in the fields: 
		| Title                  | cashier|  
		| Job id                 | KARK12 |  
		| Description            | Atleast two years work experience|  
	And I select "day" in select list "Shift"
	And I check  "job_fulltime" 
	And   I press "Update"
	Then  I should see "The job has been updated successfully."
	And   I should verify the change of title "cashier", shift "day" and jobId "KRT123"

Scenario: Deleting job successfully 
	Given I am on the jobs page
	When I click the "software developer" link 
	Then I click the "delete" link
	Then  I should see "The job has been deleted successfully."

