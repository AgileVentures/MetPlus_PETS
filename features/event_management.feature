Feature: manage notifications upon specific system events

  As a user of PETS
  I want to be notified of specific events appropriate to my role
  And receive realtime as well as email notifications

Background: seed data

  Given the default settings are present

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 |
  | MetPlus | JD    | Dave       | Developer | dave@metplus.org | qwerty123 |

  Given the following companies exist:
  | agency  | name         | website     | phone        | email            | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456799 | Active |

  Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |

  Given the following company addresses exist:
  | company      | street           | city    | state    | zipcode |
  | Widgets Inc. | 10 Spring Street | Detroit | Michigan | 02034   |

@javascript
Scenario: Job Seeker registers in PETS
  When I am in Admin's browser
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  Then I am in Paula's browser
  Then I go to the Jobseeker Registration page
  When I fill in "First Name" with "Paula"
  And I fill in "Last Name" with "Jones"
  And I fill in "Email" with "paulajones@gmail.com"
  And I fill in "Phone" with "345-890-7890"
  And I fill in "Password" with "qwerty123"
  And I fill in "Password Confirmation" with "qwerty123"
  And I select "1980" in select list "Year Of Birth"
  And I select "Unemployed Seeking" in select list "Status"
  Then I click the "Create Job seeker" button
  Then "paulajones@gmail.com" should receive an email with subject "Confirmation instructions"
  When "paulajones@gmail.com" opens the email
  Then they should see "Confirm my account" in the email body
  And "paulajones@gmail.com" follows "Confirm my account" in the email
  Then I should see "Your email address has been successfully confirmed."
  And "aa@metplus.org" should receive an email with subject "Job seeker registered"
  And "jane@metplus.org" should receive an email with subject "Job seeker registered"
  Then I am in Admin's browser
  And I should see "Job Seeker: Paula Jones has joined PETS."
  Then I go to the tasks page
  And I wait for 1 second
  And I should see "Job Seeker has no assigned Job Developer"

@javascript
Scenario: Company registration request in PETS
  When I am in Admin's browser
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  Then I am in User's browser
  Given I am on the home page
  And I click the "request PETS registration" link
  And I wait 1 second
  Then I should see "Request Company Registration"
  And I fill in the fields:
  | Company Name                   | Widgets, Inc.       |
  | Street                         | 12 Main Street      |
  | City                           | Detroit             |
  | Zipcode                        | 02034               |
  | Email                          | contact@widgets.com |
  | Fax                            | 333-222-4321        |
  | Phone                          | 222-333-4567        |
  | Website                        | www.widgets.com     |
  | EIN                            | 12-3456789          |
  | Description                    | Widgets are us!     |
  | Title                          | HR Director         |
  | First Name                     | Hugh                |
  | Last Name                      | Jobs                |
  | Contact Phone                  | 555-555-1212        |
  | Contact Email                  | hughjobs@widgets.com|
  | Password                       | qwerty123           |
  | Password Confirmation          | qwerty123           |
  And  I select "Michigan" in select list "State"
  And I click the "Create" button
  Then I should see "Thank you for your registration request."
  And "aa@metplus.org" should receive an email with subject "Company registered"
  And "jane@metplus.org" should receive an email with subject "Company registered"
  Then I am in Admin's browser
  And I should see "Company: Widgets, Inc. has registered in PETS."
  Then I go to the tasks page
  And I wait for 1 second
  And I should see "Review company registration"

@javascript
Scenario: new job posted in PETS
  When I am in Job Developer's browser
  Given I am on the home page
  And I login as "dave@metplus.org" with password "qwerty123"
  Then I am in Company Contact's browser
  Given I am on the home page
  And I login as "jane@widgets.com" with password "qwerty123"
  Then I click the "Post jobs" link
  And I fill in the fields:
		| Title            | Cashier       |
		| Company Job ID   | KARK12        |
		| Description      | Grocery Store |
	And I select "Day" in select list "Shift"
  And  I select "10 Spring Street Detroit, Michigan 02034" in select list "Job Location"
	And I check "Fulltime"
	And I press "new-job-submit"
	Then I should see "Cashier has been created successfully."
  Then "dave@metplus.org" should receive an email with subject "Job posted"
  Then I am in Job Developer's browser
  And show me the page
  And I should see "New job (Cashier) posted for company: Widgets Inc."
