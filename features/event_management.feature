Feature: manage notifications upon specific system events

  As a user of PETS
  I want to be notified of specific events appropriate to my role
  And receive realtime as well as email notifications

Background: seed data added to database and log in as agency admim

  Given the following agency roles exist:
  | role  |
  | AA    |
  | CM    |
  | JD    |

  Given the following agencies exist:
  | name    | website     | phone        | email                  | fax          |
  | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 |

  Given the following companies exist:
  | agency  | name         | website     | phone        | email            | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |

  Given the following jobseekerstatus values exist:
  | value                | description |
  | Unemployedlooking    | A jobseeker without any work and looking for a job|
  | Employedlooking      | A jobseeker with a job and looking for a job      |
  | Employednotlooking   | A jobseeker with a job and not looking for a job for now.|

@selenium
Scenario: Job Seeker registers in PETS
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  Then I go to the Jobseeker Registration page
  When I fill in "First Name" with "Paula"
  And I fill in "Last Name" with "Jones"
  And I fill in "Email" with "paulajones@gmail.com"
  And I fill in "Phone" with "345-890-7890"
  And I fill in "Password" with "qwerty123"
  And I fill in "Password Confirmation" with "qwerty123"
  And I fill in "Year Of Birth" with "1980"
  And I select "Unemployedlooking" in select list "Status"
  Then I click the "Create Job seeker" button
  Then "paulajones@gmail.com" should receive an email with subject "Confirmation instructions"
  When "paulajones@gmail.com" opens the email
  Then they should see "Confirm my account" in the email body
  And I go to the home page
  And "paulajones@gmail.com" follows "Confirm my account" in the email
  Then they should see "Your email address has been successfully confirmed."
  And I wait 10 seconds
  #Then I should see "Job Seeker: Paula Jones has joined PETS."
