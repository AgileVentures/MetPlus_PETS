Feature: Manage Jobs

As a company person or job developer
I want to create, update, and delete jobs

Background: adding job to database

  Given the default settings are present

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  | phone        |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 | 555-222-3334 |
  | MetPlus | JD    | Hugh       | Jobs      | hr@metplus.org   | qwerty123 | 555-222-3334 |

  Given the following companies exist:
  | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |
  | MetPlus | Gadgets Inc. | gadgets.com | 555-222-4444 | corp@gadgets.com | corp@gadgets.com | 12-3456791 | active |

  Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
  | title         | company_job_id  | fulltime | description | company      | creator          |
  | software dev  | KRK01K          | true     | internship  | Widgets Inc. | jane@ymail.com |

  Given the following company addresses exist:
  | company      | street       | city    | state    | zipcode |
  | Widgets Inc. | 10 Spring    | Detroit | Michigan | 02034   |
  | Widgets Inc. | 13 Summer    | Detroit | Michigan | 02054   |
  | Widgets Inc. | 16 Fall      | Detroit | Michigan | 02074   |
  | Widgets Inc. | 19 Winter    | Detroit | Michigan | 02094   |
  | Gadgets Inc. | 2 Ford Drive | Detroit | Michigan | 02094   |

Given the following job_type records:
  | job_type  |
  | Full Time |
  | Part Time |
  | Contract  |

Given the following job_shift records:
  | shift  |
  | Morning |
  | Day |
  | Swing  |

@javascript
Scenario: Creating, Updating, and Deleting Job successfully and unsuccessfully
  Given I am on the home page
  And I login as "jane@ymail.com" with password "qwerty123"
  When I click the first "Post Job" link
  And I wait 1 second
  And I should see "Salary Range"
  And I should see "Minimum"
  And I should see "Maximum"
  And I should see "Salary Period"
  And I should see "Hourly"
  And I should see "Monthly"
  And I should see "Annual"

  And I fill in the fields:
    | Title            | cashier|
    | Company Job ID   | KARK12 |
    | Description      | At least two years work experience|
  And I select "Day" in select list "Shift"
  And  I select "16 Fall Detroit, Michigan 02074" in select list "Job Location"
  And I select "Full Time" in select list "Job Type"
  And I select "Part Time" in select list "Job Type"
  And I select "Morning" in select list "Shift"
  And I press "new-job-submit"
  Then I should see "cashier has been created successfully."
  And I should see "Full Time, Part Time"
  And I should see "Morning"
  Then I click the "Edit Job" link
  And I fill in the fields:
    | Title                  | cab-driver|
    | Company Job ID         | KRT123    |
    | Description            | Atleast two years work experience|
  And  I select "19 Winter Detroit, Michigan 02094" in select list "Job Location"
  And I select "Contract" in select list "Job Type"
  And I fill in the fields:
    | Minimum | 10,000 |
    | Maximum | 20,000 |
  And I select "Monthly" in select list "Payment Period"
  And I press "Update"
  Then I should see "cab-driver has been updated successfully."
  And I should see "Full Time, Part Time, Contract"
  And I should verify the change of title "cab-driver" and jobId "KRT123"

  Then I go to the Company Person 'jane@ymail.com' Home page
  And I click the "software dev" link
  And I click the "Edit Job" link
  And  I fill in the fields:
    | Title                  | cashier|
    | Company Job ID         |  |
    | Description            |  |
  And  I select "Day" in select list "Shift"
  And  I press "edit-job-submit"
  Then  I should see "The form contains 2 errors"

  Then I fill in the fields:
    | Company Job ID | XYZ          |
    | Description    | software dev |
    | Minimum        | 20,000 |
    | Maximum        | 10,000 |

  And  I press "edit-job-submit"
  Then I should see "The form contains 2 errors"
  And I should see "Maximum salary must be greater than or equal to minimum salary"
  And I should see "Must specify payment period for salary"

  Then I fill in the fields:
    | Maximum | 20,000 |
    | Minimum |        |
  And I select "Monthly" in select list "Payment Period"

  And  I press "edit-job-submit"
  Then I should see "The form contains 1 error"
  And I should see "Minimum salary must be specified if maximum salary is set"

  When I click the "Post Job" link
  And  I fill in the fields:
    | Title                  |  |
    | Company Job ID         |  |
    | Description            |  |
  And  I select "Day" in select list "Shift"
  And  I press "new-job-submit"
  Then  I should see "The form contains 3 errors"
  And I click the "Hello, Jane" link
  And I logout

@javascript
Scenario: Cancel out of job edit
  Given I am on the home page
  And I login as "jane@ymail.com" with password "qwerty123"
  Then I should be on the Company Person 'jane@ymail.com' Home page
  And I click the "software dev" link
  And I wait 1 second
  And I should see "Revoke"
  And I click the "Edit Job" link
  And I should see "Edit Job"
  And I wait 1 second
  And I should not see "Revoke"
  And I click the "Cancel" link
  And I wait 1 second
  And I should see "Revoke"

@javascript
Scenario: Create a job *and* create new job location (company address)
  Given I am on the home page
  And I login as "jane@ymail.com" with password "qwerty123"
  When I click the first "Post Job" link
  And I wait 1 second
  And I fill in the fields:
    | Title            | cashier|
    | Company Job ID   | KARK12 |
    | Description      | At least two years work experience|
  And I select "Day" in select list "Shift"
  And  I select "16 Fall Detroit, Michigan 02074" in select list "Job Location"
  And I select "Full Time" in select list "Job Type"
  And I select "Part Time" in select list "Job Type"
  And I should not see "Street"
  And I should not see "City"
  And I click the "Create new location" link
  And I wait 1 second
  And I fill in the fields:
    | Street   | 12 Main Street |
    | City     | Detroit        |
    | Zipcode  | 02034          |
  And I press "new-job-submit"
  Then I should see "Address state can't be blank"
  Then I select "Michigan" in select list "State"
  And I press "new-job-submit"
  Then I should see "cashier has been created successfully."
  And I should see "Full Time, Part Time"

@javascript
Scenario: Edit a job *and* create new job location (company address)
  Given I am on the home page
  And I login as "jane@ymail.com" with password "qwerty123"
  And I click the "software dev" link
  And I wait 1 second
  Then I click the "Edit Job" link
  And I wait 1 second
  And I should not see "Street"
  And I should not see "City"
  And I click the "Create new location" link
  And I wait 1 second
  And I fill in the fields:
    | Street   | 10 Summer Street |
    | City     | Boston           |
    | Zipcode  | 01720            |
  Then I select "Massachusetts" in select list "State"
  And I press "edit-job-submit"
  Then I should see "10 Summer Street"
  And I should see "Boston, Massachusetts 01720"
