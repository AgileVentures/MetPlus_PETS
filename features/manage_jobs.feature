Feature: Manage Jobs  

	As a user #not quite correct  
	I want to post, edit, delete jobs 

	#@focus
	Background:
		Given the following job records:
		| title               | jobId   | shift  | fulltime | description | 
		| software developer  | KRK12K  | evening| true     | internship position with pay|  
	Scenario Outline: Updating Job successfully		
		Given I am on the jobs edit page 
		

	    When  I fill in the fields: 
			| Password              | newsecret1234 |  
			| Password confirmation | newsecret1234 |  
			| Current password      | secret1234    |  
			| First name            | Jon           |  
			| Last name             | Doe           |  
			| Phone                 | 714-123-1234  |  

		And   I press "Update"
		Then  I should see "Your account has been updated successfully."
		And   I should verify the change of first_name "Jon", last_name "Doe" and phone "714-123-1234"

		Examples: 
			| email               |
			| salemamba@gmail.com | 

	Scenario: One canceling login page 
		Given I am on the Jobseeker Registration page 
		And I press "Log In"
		Then I press "Cancel"
		And I should be on the Jobseeker Registration page 
	Scenario: Two canceling login page
		Given I am on the home page 
		And I press "Log In"
		Then I press "Cancel"
		And I should be on the home page
	# maybe fail after cancancan implementation
	Scenario: Redirecting back to previous page after successfull login 
		Given I am on the Company Registration page 
		And I am logged in as "<email>" with password "secret1234"
		And I should be on the Company Registration page