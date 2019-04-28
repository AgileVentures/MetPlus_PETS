Feature: Jobseeker Management and performs different functions

  As an jobseeker
  I want to login to PETS
  And perform various functions

Background: seed data added to database

  Given the default settings are present

  Given the following jobseekers exist:

    | first_name| last_name| email                     | phone       | password | year_of_birth |job_seeker_status  |
    | Mike      | Smith    | mike.smith@gmail.com      | 345-890-7890| password | 1990          |Unemployed Seeking |
    | thomas    | jones    | tommy1@gmail.com          | 345-890-7890| password | 1990          |Unemployed Seeking |
    | Jane      | Seeker   | jane.seeker@gmail.com    | 345-890-7890| password | 1990          |Unemployed Seeking |

  Given the following companies exist:
    | agency  | name         | website     | phone        | email          | job_email      | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
    | title   | description | company      | creator          |
    | SW dev  | develop SW  | Widgets Inc. | carter@ymail.com |
    | Trucker | drive truck | Widgets Inc. | carter@ymail.com |
    | Doctor  | heal sick   | Widgets Inc. | carter@ymail.com |
    | Clerk   | service     | Widgets Inc. | carter@ymail.com |
    | Mime    | freeze      | Widgets Inc. | carter@ymail.com |

  Given the following job applications exist:

    | job title  | job seeker           |
    | SW dev     | mike.smith@gmail.com |
    | Trucker    | mike.smith@gmail.com |
    | Doctor     | mike.smith@gmail.com |
    | Clerk      | tommy1@gmail.com     |
    | Doctor     | tommy1@gmail.com     |
    | Mime       | tommy1@gmail.com     |

  Given the following resumes exist:
    | file_name          | job_seeker             |
    | Janitor-Resume.doc | mike.smith@gmail.com |

  Given the following agency people exist:
    | agency  | role  | first_name | last_name | phone        | email          | password  |
    | MetPlus | AA,JD | John       | Smith     | 555-111-2222 | aa@metplus.org | qwerty123 |

  Given the following agency relations exist:
  	| job_seeker       | agency_person    | role |
  	| tommy1@gmail.com | aa@metplus.org   | JD   |

Scenario: JS Registration and model(s) validation
  Given I am on the Jobseeker Registration page
  When I fill in "First Name" with "test"
  And I fill in "Last Name" with "js80"
  And I fill in "Phone" with "345-890-7890"
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  And I select "1990" in select list "Year Of Birth"
  Then I select "Employed Not Looking" in select list "Status"

  # Validate email address
  And I fill in "Email" with "test.com"
  Then I click the "Create Job seeker" button
  Then I should see "Email is not formatted properly"
  And I fill in "Email" with "test@gmail"
  Then I click the "Create Job seeker" button
  Then I should see "Email is not formatted properly"
  And I fill in "Email" with "tester@.com"
  Then I click the "Create Job seeker" button
  And I should see "Email is not formatted properly"
  And I fill in "Email" with "test.addr@yahoo.com"

  # invalid résumé file type
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  And I choose resume file "Test File.zzz"
  Then I click the "Create Job seeker" button
  And I should not see "Email is not a valid address"
  And I should see "File name unsupported file type"
  And I choose resume file "Admin-Assistant-Resume.pdf"
  And I fill in "Password" with "password"
  And I fill in "Password Confirmation" with "password"
  Then I click the "Create Job seeker" button
  Then I should see "A message with a confirmation and link has been sent to your email address."

@javascript
Scenario: job seeker sees applied jobs and new job opportunities
  Given I am on the home page
  And I login as "mike.smith@gmail.com" with password "password"
  And I wait 1 second
  Then I should see "Signed in successfully"
  And I should be on the Job Seeker 'mike.smith@gmail.com' Home page
  And I click the "New Job Opportunities" link
  And I should see "SW dev"
  And I should see "Trucker"
  And I should see "Doctor"
  And I should see "Mime"
  And I should see "Clerk"

Scenario: edit Js profile
  # without password change
  Given I am on the home page
  And I login as "mike.smith@gmail.com" with password "password"
  Then I should see "Signed in successfully"
  When I click the "Hello, Mike" link
  And I click the "My Profile" link
  And I click the "Edit" link
  And I fill in "First Name" with "Mikes"
  Then I select "Employed Not Looking" in select list "Status"
  Then I click the "Update Job seeker" button
  Then I should see "Jobseeker was updated successfully."
  # edit profile with address fields missing
  Then I click the "Hello, Mike" link
  And I click the "My Profile" link
  And I click the "Edit" link
  And I fill in "City" with ""
  Then I click the "Update Job seeker" button
  Then I should see "Address city can't be blank"
  When I fill in "Street" with ""
  Then I click the "Update Job seeker" button
  Then I should see "Address street can't be blank"
  # edit profile with all address fields
  Then I click the "Mikes" link
  And I fill in "City" with "Nairobi"
  Then I fill in "Street" with "Tom Mboya"
  Then I select "Idaho" in select list "State"
  Then I click the "Update Job seeker" button
  Then I should see "Jobseeker was updated successfully."

@javascript
Scenario: Agency and Company people actions
  # admin: delete jobseeker
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I am on the JobSeeker Show page for "jane.seeker@gmail.com"
  Then I click and accept the "Delete Job Seeker" button
  And I wait 1 second
  Then I should see "Jobseeker was deleted successfully."

  # Job Developer sees job seeker's job applications
  Then I am on the JobSeeker Show page for "tommy1@gmail.com"
  And I wait 1 second
  And I should see "Clerk"
  And I should see "Doctor"
  And I should see "Mime"
  And I should not see "Trucker"

  # agency person: no download button when no job seeker résumé
  Then I am on the JobSeeker Show page for "tommy1@gmail.com"
  And I wait 1 second
  Then I should not see button "Download Resume"

  # agency person: download job seeker résumé
  Then I am on the JobSeeker Show page for "mike.smith@gmail.com"
  And I wait 1 second
  Then I should see button "Download Resume"
  And I click the "Download Resume" button

  # company admin: download job seeker résumé
  And I click the "Hello, John" link
  Then I logout
  And I am logged in as "carter@ymail.com" with password "qwerty123"
  And I wait 1 second
  And I should see "SW dev"
  When I click the "SW dev" link
  And I wait 1 second
  And I should see "Applications for this Job"
  Then I click the "Smith, Mike" link
  Then I should see button "Download Resume"
  And I click the "Download Resume" button
