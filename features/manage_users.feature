Feature: Manage Users 

As a user 
I want to login 
So that I can edit my profiles

#@focus
Scenario Outline: Show edit link as salem
	Given the following user records:
		| email               | password   | password_confirmation | first_name | last_name | phone          | confirmed_at                      |  
		| salemamba@gmail.com | secret1234 | secret1234            | salem      | amba      | (619) 123-1234 | "Sat, 14 Nov 2015 22:52:26 -0800" |  
	Given I am logged in as "<email>" with password "secret1234"
	And   I visit profile for "salem"
	Then  I should see "Edit User"

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

	

