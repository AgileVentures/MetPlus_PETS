Feature: Manage Jobs

  As a company person or job developer
  I want to create, update, and delete jobs

  Background: adding job to database

    Given the default settings are present

    Given the following agency people exist:
      | agency  | role | first_name | last_name | email          | password  |        phone |
      | MetPlus | AA   | John       | Smith     | aa@metplus.org | qwerty123 | 555-222-3334 |
      | MetPlus | JD   | Hugh       | Jobs      | hr@metplus.org | qwerty123 | 555-222-3334 |

    Given the following companies exist:
      | agency  | name         | website     |        phone | email            | job_email        |        ein | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com   | corp@ymail.com   | 12-3456789 | active |
      | MetPlus | Gadgets Inc. | gadgets.com | 555-222-4444 | corp@gadgets.com | corp@gadgets.com | 12-3456791 | active |

    Given the following company people exist:
      | company      | role | first_name | last_name | email          | password  |        phone |
      | Widgets Inc. | CC   | Jane       | Smith     | jane@ymail.com | qwerty123 | 555-222-3334 |

    Given the following jobs exist:
      | title        | company_job_id | description         | company      | creator        |
      | software dev | KRK01K         | internship          | Widgets Inc. | jane@ymail.com |
      | editor       | T01KS          | This will be edited | Widgets Inc. | jane@ymail.com |

    Given the following company addresses exist:
      | company      | street       | city    | state    | zipcode |
      | Widgets Inc. | 10 Spring    | Detroit | Michigan |   02034 |
      | Widgets Inc. | 13 Summer    | Detroit | Michigan |   02054 |
      | Widgets Inc. | 16 Fall      | Detroit | Michigan |   02074 |
      | Widgets Inc. | 19 Winter    | Detroit | Michigan |   02094 |
      | Gadgets Inc. | 2 Ford Drive | Detroit | Michigan |   02094 |

    Given the following job_type records:
      | job_type  |
      | Full Time |
      | Part Time |
      | Contract  |

    Given the following job_shift records:
      | shift   |
      | Morning |
      | Day     |
      | Swing   |

    Given the following license records:
      | abbr  | title                                  |
      | LLMSW | LIMITED LICENSE MASTER SOCIAL WORKER   |
      | LMSW  | LICENSED MASTER SOCIAL WORKER          |
      | LLPC  | LIMITED LICENSE PROFESSIONAL COUNSELOR |


    Given the following education records:
      | level             | rank |
      | High School       |   1  |
      | Associates Degree |   2  |
      | Bachelors Degree  |   3  |
      | Masters Degree    |   4  |
      | PhD               |   5  |
      | Other             |   6  |

    Given I am on the home page
    And I login as "jane@ymail.com" with password "qwerty123"

  @javascript
  Scenario: Visit the job create page
    When I click the first "Post Job" link
    And I wait 1 second
    And I should see "Salary Range"
    And I should see "Minimum"
    And I should see "Maximum"
    And I should see "Hourly"
    And I should see "Weekly"
    And I should see "Monthly"
    And I should see "Annually"

  @javascript
  Scenario: Creating Job Successfully
    When I click the first "Post Job" link
    And I wait 1 second
    And I fill in the fields:
      | Title          | cashier                            |
      | Company Job ID | KARK12                             |
      | Description    | At least two years work experience |
    And I select "Day" in select list "Shift"
    And  I select "16 Fall Detroit, Michigan 02074" in select list "Job Location"
    And I select "Full Time" in select list "Job Type"
    And I select "Part Time" in select list "Job Type"
    And I select "Morning" in select list "Shift"
    Then I select a license
    And I press "new-job-submit"
    Then I should see "cashier has been created successfully."
    And the job "cashier" should have 1 license
    And I should see "LLMSW (LIMITED LICENSE MASTER SOCIAL WORKER)"


  @javascript
  Scenario: Updating a job successfully
    When I click the "editor" link
    And I wait 1 second
    Then I click the "Edit Job" link
    And I fill in the fields:
      | Title                | cab-driver                        |
      | Company Job ID       | KRT123                            |
      | Description          | Atleast two years work experience |
      | Language Proficiency | Must speak fluent english         |
    And  I select "19 Winter Detroit, Michigan 02094" in select list "Job Location"
    And I select "Contract" in select list "Job Type"
    And I select "Part Time" in select list "Job Type"
    And I fill in the fields:
      | Minimum | 10000 |
      | Maximum | 20000 |
    And I choose the "Monthly" radio button
    Then I select a license
    And I press "Update"
    Then I should see "cab-driver has been updated successfully."
    And the job "cab-driver" should have 1 license
    And I should see "Part Time, Contract"
    And I should see "Must speak fluent english"
    And I should verify the change of title "cab-driver" and jobId "KRT123"

    Then I click the "Edit Job" link
    And I select radio button "Associates Degree"
    And I fill in "Additional Information:" with "also need XYZ training"
    And I press "Update"
    Then I should see "cab-driver has been updated successfully."
    And I should see "Associates Degree"
    And I should see "also need XYZ training"

    Then I click the "Edit Job" link
    And I select another license
    And I press "Update"
    And the job "cab-driver" should have 2 licenses
    And I should see "LLMSW (LIMITED LICENSE MASTER SOCIAL WORKER)"
    And I should see "LLPC (LIMITED LICENSE PROFESSIONAL COUNSELOR)"

    Then I click the "Edit Job" link
    Then I wait for 1 second
    And I click the first "remove license" link
    And I press "Update"
    And the job "cab-driver" should have 1 license
    And I should see "LLPC (LIMITED LICENSE PROFESSIONAL COUNSELOR)"

    Then I go to the Company Person 'jane@ymail.com' Home page
    And I click the "software dev" link
    And I click the "Edit Job" link
    And  I fill in the fields:
      | Title          | cashier |
      | Company Job ID |         |
      | Description    |         |
    And  I select "Day" in select list "Shift"
    And  I press "edit-job-submit"
    Then  I should see "The form contains 2 errors"

    Then I fill in the fields:
      | Company Job ID |          XYZ |
      | Description    | software dev |
      | Minimum        |        20000 |
      | Maximum        |        10000 |

    And  I press "edit-job-submit"
    Then I should see "The form contains 2 errors"
    And I should see "Max salary cannot be less than minimum salary"
    And I should see "Pay period must be specified"

    Then I fill in the fields:
      | Maximum | 20000 |
      | Minimum |       |
    And I choose the "Monthly" radio button

    And  I press "edit-job-submit"
    Then I should see "The form contains 1 error"
    And I should see "Min salary must be specified if maximum salary is specified"

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
    When I click the first "Post Job" link
    And I wait 1 second
    And I fill in the fields:
      | Title          | cashier                            |
      | Company Job ID | KARK12                             |
      | Description    | At least two years work experience |
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
    And I should see "Full Time"
    And I should see "Part Time"

  @javascript
  Scenario: Edit a job *and* create new job location (company address)
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
