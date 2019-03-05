Feature: agency admin logs in and performs admin functions

  As an agency admin
  I want to login to PETS
  And perform various administrative functions

Background: seed data added to database and log in as agency admim

  Given the default settings are present

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  | phone        |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 | 555-222-3334 |
  | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 | 555-222-3334 |
  | MetPlus | JD    | Mike       | Check     | mike@metplus.org | qwerty123 | 555-222-3334 |

  Given the following agency branches exist:
  | agency  | state     | city     | street              | zipcode | code |
  | MetPlus | Michigan  |  Detroit | 123 Main Street     | 48201   | 001  |
  | MetPlus | Michigan  |  Detroit | 456 Sullivan Street | 48204   | 002  |
  | MetPlus | Mighigan  |  Detroit | 3 Auto Drive        | 48206   | 003  |

  Given the following job categories exist:
  | name                      | description                         |
  | Software Engineer - RoR   | Develop website using Ruby on Rails |

  Given the following job skills exist:
  | name                      | description                         |
  | Web Research              | Hic deleniti explicabo inventore delectus veritatis mollitia. |
  | Visual Analysis           | Incidunt aut magni perferendis atque qui dolor.               |

  Given the following license records:
    | abbr  | title                                  |
    | LLMSW | LIMITED LICENSE MASTER SOCIAL WORKER   |
    | LMSW  | LICENSED MASTER SOCIAL WORKER          |
    | LLPC  | LIMITED LICENSE PROFESSIONAL COUNSELOR |

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |
    | MetPlus | Gadgets Inc. | gadgets.com | 555-222-4444 | corp@gadgets.com | corp@gadgets.com | 12-3456791 | active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
  | title         | company_job_id  | description | company      | creator        | skills       | licenses |
  | Web dev       | KRK01K          | internship  | Widgets Inc. | jane@ymail.com | Web Research | LLMSW    |

  Given the following jobseekers exist:
  | first_name| last_name| email            | phone       | password  | year_of_birth |job_seeker_status  |
  | Sam       | Seeker   | sammy1@gmail.com | 222-333-4444| password  | 1990          |Unemployed Seeking |
  | Tom       | Terrific | tommy1@gmail.com | 333-444-5555| password  | 1990          |Unemployed Seeking |

  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"
  And I click the "Admin" link

@javascript
Scenario: navigate data tables - agency and job properties
  And I click the "Agency and Partner Companies" link
  Then "pets_admin@metplus.org" should be visible
  Then I click the "Agency Branches" link
  And  I wait 1 second
  Then "pets_admin@metplus.org" should not be visible
  And "123 Main Street" should be visible
  Then I click the "Agency Personnel" link
  And  I wait 1 second
  Then "123 Main Street" should not be visible
  And "Smith, John" should be visible

Scenario: edit agency information
  And I click the "Agency and Partner Companies" link
  Then "pets_admin@metplus.org" should be visible
  Then I click the "Edit Agency" button
  Then I should see "METPLUS"
  And I fill in "Name" with "MetPlus Two"
  And I click "Update Agency" button
  Then I should see "Agency was successfully updated."
  And I should see "MetPlus Two"
  # cancel edit
  Then I click the "Edit Agency" button
  And I fill in "Name" with "MetPlus Three"
  And I click the "Cancel" link
  And  I wait 1 second
  Then I should not see "Agency was successfully updated."
  And I should see "MetPlus Two"
  # data errors in agency edit form
  Then I click the "Edit Agency" button
  And I fill in "Phone" with ""
  And I fill in "Website" with "nodomain"
  And I click "Update Agency" button
  Then I should see "The form contains 3 errors"
  And I should see "Phone can't be blank"
  And I should see "Phone incorrect format"
  And I should see "Website is not a valid website address"

Scenario: edit branch information
  And I click the "Agency and Partner Companies" link
  Then "pets_admin@metplus.org" should be visible
  Then I click the "Agency Branches" link
  And  I wait 1 second
  Then I click the "001" link
  And  I wait 1 second
  Then I should see "Branch Code:"
  Then I click the "Edit Branch" button
  Then I should see "Edit Branch"
  And I fill in "Branch Code" with "004"
  And I fill in "City" with "San Jose"
  Then I select "California" in select list "State"
  And I click the "Update" button
  Then I should see "Branch was successfully updated."
  # cancel edit branch
  Then I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Branches" link
  And I click the "004" link
  Then I click the "Edit Branch" button
  Then I should see "Edit Branch"
  And I fill in "Branch Code" with "005"
  Then I click the "Cancel" link
  And I wait 1 second
  Then I should see "Agency Branch"
  And I should not see "005"
  # data errors in branch edit form
  Then I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Branches" link
  And I click the "004" link
  Then I click the "Edit Branch" button
  And I fill in "Branch Code" with "002"
  And I fill in "Zipcode" with "1234567"
  And I click the "Update" button
  Then I should see "The form contains 2 errors"
  And I should see "Code has already been taken"
  And I should see "Address zipcode should be in form of 12345 or 12345-1234"
  # new agency branch
  Then I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Branches" link
  And I click the "Add Branch" button
  Then I fill in "Branch Code" with "005"
  And I fill in "Street" with "10 Ford Way"
  And I fill in "City" with "Detroit"
  Then I select "Michigan" in select list "State"
  And I fill in "Zipcode" with "48208"
  And I click the "Create" button
  Then I should see "Branch was successfully created."
  # cannot remove sole agency admin
  Then I click the "Admin" link
  Then I click the "Agency Personnel" link
  And I wait 3 seconds
  And I click the "Smith, John" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: John Smith"
  And I should see "Agency Admin"
  And the selection "Agency Admin" should be disabled

Scenario: edit agency person
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Personnel" link
  Then I click the "Jones, Jane" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Jane Jones"
  Then I select "002" in select list "Branch"
  And I check "Agency Admin"
  And I click the "Update" button
  Then I should see "Agency person was successfully updated."
  And I should see "Jane Jones"
  And I should see "002"
  And I should see "Agency Admin"
  # cancel edit agency person
  Then I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Personnel" link
  And I click the "Jones, Jane" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Jane Jones"
  Then I select "003" in select list "Branch"
  Then I click the "Cancel" link
  And I wait 1 second
  And I should see "Jane Jones"
  And I should not see "003"
  # non-admin does not see 'admin' in menu
  Given I click the "John" link
  Given I log out
  And I wait 1 second
  Given I am on the home page
  And I login as "mike@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should not see "Admin"

@javascript
Scenario: delete agency objects
  # branch
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Branches" link
  And  I wait 1 second
  And I click the "003" link
  Then I click and accept the "Delete Branch" button
  Then I should see "Branch '003' deleted."
  # agency person
  Then I click the "Agency Personnel" link
  And I click the "Jones, Jane" link
  Then I click and accept the "Delete Person" button
  Then I should see "Person 'Jane Jones' deleted."

@email
Scenario: assign job seeker to agency person
  # case manager
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Personnel" link
  And I click the "Jones, Jane" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Jane Jones"
  Then I check second "Seeker, Sam"
  And I check second "Terrific, Tom"
  And I click the "Update" button
  Then I should see "Agency person was successfully updated."
  And I should see "Seeker, Sam" after "Assigned Job Seekers to Jane Jones as Case Manager:"
  And I should see "Terrific, Tom" after "Assigned Job Seekers to Jane Jones as Case Manager:"
  Then "jane@metplus.org" should receive 2 emails with subject "Job seeker assigned cm"
  When "jane@metplus.org" opens the email
  Then they should see "A job seeker has been assigned to you as Case Manager:" in the email body
  When "jane@metplus.org" follows "Sam Seeker" in the email
  Then they should see "Sam Seeker" after "Name"
  # job developer
  Then I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Agency Personnel" link
  And  I wait 1 second
  And I click the "Check, Mike" link
  Then I click the "Edit Person" button
  And I should see "Edit Agency Person: Mike Check"
  Then I check first "Seeker, Sam"
  And I check first "Terrific, Tom"
  And I click the "Update" button
  Then I should see "Agency person was successfully updated."
  And I should see "Seeker, Sam" after "Assigned Job Seekers to Mike Check as Job Developer:"
  And I should see "Terrific, Tom" after "Assigned Job Seekers to Mike Check as Job Developer:"
  Then "mike@metplus.org" should receive 2 emails with subject "Job seeker assigned jd"
  When "mike@metplus.org" opens the email
  Then they should see "A job seeker has been assigned to you as Job Developer:" in the email body
  When "mike@metplus.org" follows "Sam Seeker" in the email
  Then they should see "Sam Seeker" after "Name"

@javascript
@email
Scenario: manage job properties
  # add job specialty
  And I click the "Job Properties" link
  And I wait 1 second
  And I click the "Add job specialty" button
  And I wait 1 second
  And I fill in "Name:" with "Test Job Specialty"
  And I fill in "Description:" with "Description of Test Job Specialty"
  And I click the "Add Specialty" button
  And I wait 1 second
  Then I should see "Test Job Specialty"
  And I should see "Description of Test Job Specialty"

  # cancel add job specialty
  And I click the "Add job specialty" button
  And I fill in "Name:" with "Test 2nd Job Specialty"
  And I click the "Cancel" button
  Then I should not see "Test 2nd Job Specialty"
  And I should not see "Description of 2nd Test Job Specialty"

  # show job specialty model validation errors
  Then I click the "Add job specialty" button
  And I wait 1 second
  And I fill in "Name:" with ""
  And I fill in "Description:" with ""
  And I click the "Add Specialty" button
  And I wait 1 second
  Then I should see "Name can't be blank"
  And I should see "Description can't be blank"
  Then I fill in "Name:" with "Test 3rd Job Specialty"
  And I fill in "Description:" with "Description of 3rd Test Job Specialty"
  And I click the "Add Specialty" button
  And I wait 1 second
  Then I should see "Test 3rd Job Specialty"
  And I should see "Description of 3rd Test Job Specialty"

  # update job specialty
  And I click the "Software Engineer - RoR" link
  And I wait 1 seconds
  And I fill in "Description:" with ""
  And I click the "Update Specialty" button
  And I wait 1 second
  Then I should see "Description can't be blank"
  And I fill in "Description:" with "Backend RoR Development"
  And I click the "Update Specialty" button
  And I wait 1 second
  Then "Update Job Specialty" should not be visible
  And I should see "Backend RoR Development"

  # delete job specialty
  And I click the "Delete" link with url "/job_categories/1"
  # And I wait 1 second
  Then I should not see "Software Engineer - RoR"

  # add job skill
  And I click the "Job Skills" link
  And I click the "Add job skill" button
  And I fill in "Name:" with "Test Job Skill"
  And I fill in "Description:" with "Description of Test Job Skill"
  And I click the "Add Skill" button
  Then I should see "Test Job Skill"
  And I should see "Description of Test Job Skill"

  # cancel add job skill
  And I click the "Add job skill" button
  And I fill in "Name:" with "Test 2nd Job Skill"
  And I click the "Cancel" button
  Then I should not see "Test 2nd Job Skill"

  # show job skill model validation errors
  Then I click the "Add job skill" button
  And I fill in "Name:" with ""
  And I fill in "Description:" with ""
  And I click the "Add Skill" button
  Then I should see "Name can't be blank"
  And I should see "Description can't be blank"
  Then I fill in "Name:" with "Test 3rd Job Skill"
  And I fill in "Description:" with "Description of 3rd Test Job Skill"
  And I click the "Add Skill" button
  Then I should see "Test 3rd Job Skill"

  # update job skill
  And I click the "Web Research" link
  And I wait 1 second
  And I fill in "Description:" with ""
  And I click the "Update Skill" button
  And I wait 1 second
  And I should see "Description can't be blank"
  And I fill in "Description:" with "Anaytics using web data"
  And I click the "Update Skill" button
  And I wait 1 second
  Then "Update Job Skill" should not be visible
  And I should see "Anaytics using web data"

  # delete job skill not associated with a job
  And I click the "Delete" link with url "/skills/2"
  Then I should not see "Visual Analysis"

  # attempt to delete job skill associated with a job
  And I should not see the "/skills/1" link

  # add license
  And I click the "Licenses" link
  And I click the "Add license" button
  And I fill in "Abbreviation:" with "TEST"
  And I fill in "Title:" with "Some Standard License"
  And I click the "Add License" button
  Then I should see "TEST"
  And I should see "Some Standard License"

  # cancel add license
  And I click the "Add license" button
  And I fill in "Abbreviation:" with "TEST2"
  And I click the "Cancel" button
  Then I should not see "TEST2"

  # show license model validation errors
  Then I click the "Add license" button
  And I fill in "Abbreviation:" with ""
  And I fill in "Title:" with ""
  And I click the "Add License" button
  Then I should see "Abbr can't be blank"
  And I should see "Title can't be blank"
  Then I fill in "Abbreviation:" with "TEST3"
  And I fill in "Title:" with "Description of 3rd Test License"
  And I click the "Add License" button
  Then I should see "TEST3"

  # update license
  And I click the "LLPC" link
  And I wait 1 second
  And I fill in "Abbreviation:" with ""
  And I click the "Update License" button
  And I wait 1 second
  And I should see "Abbr can't be blank"
  And I fill in "Abbreviation:" with "ABC"
  And I click the "Update License" button
  And I wait 1 second
  Then "Update License" should not be visible
  And I should see "ABC"

  # delete license not associated with a job
  And I click the "Delete" link with url "/licenses/2"
  Then I should not see "LICENSED MASTER SOCIAL WORKER"

  # attempt to delete license associated with a job
  And I should not see the "/skills/1" link
