Feature: Jobseeker Management and performs different functions
  
  As an jobseeker 
  I want to login to PETS
  And perform various functions

Background: seed data added to database
    
  Given the following jobseeker exist:
  | first_name| last_name| email                      | phone       |password  |password_confirmation| year_of_birth |
  | vijaya      | karumudi     | vijaya.karumudi@gmail.com | 345-890-7890| password   |password               | 1990          |
  

Scenario: new Js Registration
  Given I am on the Jobseeker Registration page
  When I fill in "First Name" with "test"
  And I fill in "Last Name" with "js80"
  And I fill in "Email" with "testjobseeker80@gmail.com"
  And I fill in "Phone" with "345-890-7890"
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  And I fill in "Year Of Birth" with "1990"
  Then I click the "Create Job seeker" button 
  Then I wait for 30 seconds 
  Then I should see "A message with a confirmation and link has been sent  to your email address. Please follow the link to activate your account."


Scenario: login action as jobseeker
  Given I am on the home page
  And I login as "vijaya.karumudi@gmail.com" with password "password"
  Then I should see "Signed in successfully."

Scenario: edit Js Registration
  Given I am on the home page
  And I login as "vijaya.karumudi@gmail.com" with password "password"
  Then I should see "Signed in successfully"
  When I click the "vijaya" link
  And I fill in "First Name" with "vijaya1" 
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  Then I click the "Update Job seeker" button 
  Then I wait for 10 seconds
  Then I should see "Jobseeker was updated successfully."
     



    
  



