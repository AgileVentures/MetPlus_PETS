Feature: Jobseeker Management and performs different functions

  As an jobseeker
  I want to login to PETS
  And perform various functions

Background: seed data added to database

  Given the default settings are present

  Given the following jobseeker exist:
  | first_name| last_name| email                     | phone       | password   |password_confirmation| year_of_birth |job_seeker_status  |
  | vijaya    | karumudi | vijaya.karumudi@gmail.com | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |

Scenario: new Js Registration
  Given I am on the Jobseeker Registration page
  When I fill in "First Name" with "test"
  And I fill in "Last Name" with "js80"
  And I fill in "Email" with "testjobseeker80@gmail.com"
  And I fill in "Phone" with "345-890-7890"
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  And I select "1990" in select list "Year Of Birth"
  Then I select "Employed Not Looking" in select list "Status"
  And I choose resume file "Admin-Assistant-Resume.pdf"
  Then I click the "Create Job seeker" button
  Then I should see "A message with a confirmation and link has been sent to your email address. Please follow the link to activate your account."

Scenario: Invalid résumé file type
  Given I am on the Jobseeker Registration page
  When I fill in "First Name" with "test"
  And I fill in "Last Name" with "js80"
  And I fill in "Email" with "testjobseeker80@gmail.com"
  And I fill in "Phone" with "345-890-7890"
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  And I select "1990" in select list "Year Of Birth"
  Then I select "Employed Not Looking" in select list "Status"
  And I choose resume file "Test File.zzz"
  Then I click the "Create Job seeker" button
  Then I should see "File name unsupported file type"

Scenario: login action as jobseeker
  Given I am on the home page
  And I login as "vijaya.karumudi@gmail.com" with password "password"
  Then I should see "Signed in successfully."
  And I should be on the Job Seeker 'vijaya.karumudi@gmail.com' Home page
  And I should see "vijaya"

Scenario: jobseeker homepage with no agency relations
  Given I am on the home page
  And I login as "vijaya.karumudi@gmail.com" with password "password"
  Then I should see "Signed in successfully."
  And I should be on the Job Seeker 'vijaya.karumudi@gmail.com' Home page
  And I should see "First Name: vijaya"
  And I should see "Case Manager: None assigned"
  And I should see "Job Developer: None assigned"

Scenario: edit Js Registration
  Given I am on the home page
  And I login as "vijaya.karumudi@gmail.com" with password "password"
  Then I should see "Signed in successfully"
  When I click the "vijaya" link
  And I fill in "First Name" with "vijaya1"
  And I fill in "Zipcode" with "54321"
  Then I select "Employed Not Looking" in select list "Status"
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  Then I click the "Update Job seeker" button
  Then I should see "Jobseeker was updated successfully."
  When I click the "vijaya" link
  Then The field 'First Name' should have the value 'vijaya1'
  And The field 'Zipcode' should have the value '54321'

Scenario: edit Js Registration without password change
  Given I am on the home page
  And I login as "vijaya.karumudi@gmail.com" with password "password"
  Then I should see "Signed in successfully"
  When I click the "vijaya" link
  And I fill in "First Name" with "vijaya1"
  Then I select "Employed Not Looking" in select list "Status"
  Then I click the "Update Job seeker" button
  Then I should see "Jobseeker was updated successfully."

@javascript
Scenario: delete jobseeker
  Given I am on the JobSeeker Show page for "vijaya.karumudi@gmail.com"
  Then I click and accept the "Delete Jobseeker" button
  And I wait for 1 seconds
  Then I should see "Jobseeker was deleted successfully."

Scenario:cancel redirect to homepage
  Given I am on the JobSeeker Show page for "vijaya.karumudi@gmail.com"
  Then I click the "Cancel" link
  Then I should be on the home page
