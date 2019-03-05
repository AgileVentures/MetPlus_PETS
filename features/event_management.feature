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
  | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456799 | active |

  Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com | qwerty123 | 555-222-3334 |

  Given the following company addresses exist:
  | company      | street           | city    | state    | zipcode |
  | Widgets Inc. | 10 Spring Street | Detroit | Michigan | 02034   |

  Given the following jobseekers exist:
  | first_name| last_name| email         | phone       | password  | year_of_birth |job_seeker_status  |
  | Sam       | Seeker   | sammy1@gmail.com | 222-333-4444| qwerty123 | 1990          |Unemployed Seeking |
  | Tom       | Terrific | tommy1@gmail.com | 333-444-5555| qwerty123 | 1990          |Unemployed Seeking |

@email
@selenium
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

@email
@javascript
Scenario: Company registration request in PETS
  When I am in Admin's browser
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  Then I am in User's browser
  Given I am on the home page
  And I click the "Register as an Employer" link
  And I wait 1 second
  Then I should see "Request Company Registration"
  And I fill in the fields:
  | Company Name                   | Widgets, Inc.       |
  | Street                         | 12 Main Street      |
  | City                           | Detroit             |
  | Zipcode                        | 02034               |
  | Email                          | contact@ymail.com   |
  | Job Email                      | hr_dept@ymail.com   |
  | Fax                            | 333-222-4321        |
  | Phone                          | 222-333-4567        |
  | Website                        | www.widgets.com     |
  | EIN                            | 12-3456789          |
  | Description                    | Widgets are us!     |
  | Title                          | HR Director         |
  | First Name                     | Hugh                |
  | Last Name                      | Jobs                |
  | Contact Phone                  | 555-555-1212        |
  | Contact Email                  | hughjobs@ymail.com  |
  | Password                       | qwerty123           |
  | Password Confirmation          | qwerty123           |
  And  I select "Michigan" in select list "State"
  And I click the "Create" button
  Then I should see "Thank you for your registration request."
  And "aa@metplus.org" should receive an email with subject "Company registered"
  And "jane@metplus.org" should receive an email with subject "Company registered"
  Then I am in Admin's browser
  And I wait 1 second
  And I should see "Company: Widgets, Inc. has registered in PETS."

  # The following steps tests the user clicking a link
  # in a popup notification and being redirected to a new tab/window.
  # This is commented out because it fails intermittently and often.

  # Then I click the "Widgets, Inc." link and switch to the new window
  # And I should see "Company Information"
  # And I should see "Widgets, Inc."

  Then I go to the tasks page
  And I wait for 1 second
  And I should see "Review company registration"

@email
@javascript
Scenario: Job developer assigned to job seeker by agency admin
  When I am in Job Seeker's browser
  Given I am on the home page
  And I login as "sammy1@gmail.com" with password "qwerty123"
  Then I should see "Signed in successfully."
  When I am in Job Developer's browser
  Given I am on the home page
  And I login as "dave@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  When I am in Admin's browser
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  And I wait 1 second
  Then I click the "Agency Personnel" link
  And I click the "Developer, Dave" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Dave Developer"
  Then I check first "Seeker, Sam"
  And I click the "Update" button
  Then I should see "Agency person was successfully updated."
  And I should see "Seeker, Sam" after "Assigned Job Seekers to Dave Developer as Job Developer:"
  Then I am in Job Seeker's browser
  And I should see "Dave Developer has been assigned to you as your MetPlus Job Developer"
  Then I am in Job Developer's browser
  And I should see "Job Seeker: Sam Seeker has been assigned to you as Job Developer"
  And "sammy1@gmail.com" should receive an email with subject "Job developer assigned"
  When "sammy1@gmail.com" opens the email
  Then they should see "Dave Developer" in the email body
  And they should see "has been assigned to you as your MetPlus Job Developer" in the email body
  And "dave@metplus.org" should receive an email with subject "Job seeker assigned jd"
  When "dave@metplus.org" opens the email
  Then they should see "A job seeker has been assigned to you as Job Developer:" in the email body
  When "dave@metplus.org" follows "Sam Seeker" in the email
  Then they should see "Sam Seeker" after "Name"

@email
@javascript
Scenario: Case manager assigned to job seeker by agency admin
  When I am in Job Seeker's browser
  Given I am on the home page
  And I login as "sammy1@gmail.com" with password "qwerty123"
  Then I should see "Signed in successfully."
  When I am in Case Manager's browser
  Given I am on the home page
  And I login as "jane@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  When I am in Admin's browser
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  And I wait 1 second
  Then I click the "Agency Personnel" link
  And I click the "Jones, Jane" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Jane Jones"
  Then I check second "Seeker, Sam"
  And I click the "Update" button
  Then I should see "Agency person was successfully updated."
  And I should see "Seeker, Sam" after "Assigned Job Seekers to Jane Jones as Case Manager:"
  Then I am in Job Seeker's browser
  And I should see "Jane Jones has been assigned to you as your MetPlus Case Manager"
  Then I am in Case Manager's browser
  And I should see "Job Seeker: Sam Seeker has been assigned to you as Case Manager"
  And "sammy1@gmail.com" should receive an email with subject "Case manager assigned"
  When "sammy1@gmail.com" opens the email
  Then they should see "Jane Jones" in the email body
  And they should see "has been assigned to you as your MetPlus Case Manager" in the email body
  And "jane@metplus.org" should receive an email with subject "Job seeker assigned cm"
  When "jane@metplus.org" opens the email
  Then they should see "A job seeker has been assigned to you as Case Manager:" in the email body
  When "jane@metplus.org" follows "Sam Seeker" in the email
  Then they should see "Sam Seeker" after "Name"

@email
@javascript
Scenario: Job developer assigns self to job seeker
  When I am in Job Seeker's browser
  Given I am on the home page
  And I login as "sammy1@gmail.com" with password "qwerty123"
  Then I should see "Signed in successfully."
  When I am in Job Developer's browser
  Given I am on the home page
  And I login as "dave@metplus.org" with password "qwerty123"
  And I wait 2 seconds
  Then I should see "Signed in successfully."
  And I click the "Job Seekers without a JD" link
  And I wait 1 second
  And I should see "Seeker, Sam"
  And I click the "Seeker, Sam" link
  And I wait 1 second
  And I should see "Assign Myself"
  And I click the "Assign Myself" button
  And I wait 2 seconds
  And I should see "Dave Developer" after "Job Developer"
  And I should not see "Assign Myself"
  Then I am in Job Seeker's browser
  And I should see "Dave Developer has been assigned to you as your MetPlus Job Developer"
  And "sammy1@gmail.com" should receive an email with subject "Job developer assigned"
  When "sammy1@gmail.com" opens the email
  Then they should see "Dave Developer" in the email body
  And they should see "has been assigned to you as your MetPlus Job Developer" in the email body

@javascript
@email
Scenario: Case manager assigns self to job seeker
  When I am in Job Seeker's browser
  Given I am on the home page
  And I login as "sammy1@gmail.com" with password "qwerty123"
  Then I should see "Signed in successfully."
  When I am in Case Manager's browser
  Given I am on the home page
  And I login as "jane@metplus.org" with password "qwerty123"
  And I wait 2 seconds
  Then I should see "Signed in successfully."
  And I click the "Job Seekers without a CM" link
  And I wait 1 second
  And I should see "Seeker, Sam"
  And I click the "Seeker, Sam" link
  And I wait 1 second
  And I should see "Assign Myself"
  And I click the "Assign Myself" button
  And I wait 1 second
  And I should see "Jane Jones" after "Case Manager"
  And I should not see "Assign Myself"
  Then I am in Job Seeker's browser
  And I should see "Jane Jones has been assigned to you as your MetPlus Case Manager"
  And "sammy1@gmail.com" should receive an email with subject "Case manager assigned"
  When "sammy1@gmail.com" opens the email
  Then they should see "Jane Jones" in the email body
  And they should see "has been assigned to you as your MetPlus Case Manager" in the email body
