Feature: Apply to a job

  As a job seeker
  I want to apply to a job

  Background: adding job to database
    Given the default settings are present

    Given the following agency people exist:
      | agency  | role  | first_name | last_name | email            | password  |
      | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
      | MetPlus | JD    | Jane       | Jones     | jane@metplus.org | qwerty123 |
      | MetPlus | CM    | Mike       | Manager   | mike@metplus.org | qwerty123 |


    Given the following companies exist:
      | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
      | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456780 | active |
      | MetPlus | ACME         | acme.com    | 335-222-3333 | corp@gmail.com | corp@gmail.com | 12-3456789 | active |

    Given the following company people exist:
      | company      | role  | first_name | last_name | email            | password  | phone        |
      | ACME         | CC    | John       | Smith     | carter@ymail.com   | qwerty123 | 555-222-3334 |
      | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com | qwerty123 | 555-222-3334 |

    Given the following jobs exist:
      | title    | company_job_id  | description | company      | creator          |
      | editor   | T01KS           | full time   | Widgets Inc. | jane@ymail.com   |
      | developer| KRK01K          | internship  | ACME         | carter@ymail.com |

    Given the following jobseekers exist:
      | first_name| last_name| email                     | phone       | password   |password_confirmation| year_of_birth |job_seeker_status |
      | John      | Seeker   | john.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |

    Given the following agency relations exist:
      | job_seeker             | agency_person    | role |
      | john.seeker@gmail.com | jane@metplus.org | JD   |
      | john.seeker@gmail.com | mike@metplus.org | CM   |

    Given the following job applications exist:
      | job title          | job seeker            |
      | editor             | john.seeker@gmail.com |
      | developer          | john.seeker@gmail.com |

  @javascript
  Scenario: Job seeker applies to job

    Given I am on the home page
    And I login as "john.seeker@gmail.com" with password "password"
    Then I should see "Signed in successfully"
    Then I click the first "Home" link
    And I should see "Your Applications"
    And I should see a link "Title" pointing to "job_title+asc"
    And I should see a link "Description" pointing to "description+asc"
    And I should see a link "Company" pointing to "job_company_name+asc"
    And I should see a link "Applied" pointing to "created_at+asc"
    And I should not see a link "Title" pointing to "job_title+desc"
    And I should not see a link "Description" pointing to "description+desc"
    And I should not see a link "Company" pointing to "job_company_name+desc"
    And I should not see a link "Applied" pointing to "created_at+desc"

    Then I click the "Title" link
    And I wait for 1 second
    And I should see a link "Title" pointing to "job_title+desc"
    And I should not see a link "Title" pointing to "job_title+asc"
    And page should have "developer" before "editor"
    Then I click the "Title" link
    And I wait for 1 second
    And I should see a link "Title" pointing to "job_title+asc"
    And I should not see a link "Title" pointing to "job_title+desc"
    And page should have "editor" before "developer"

    Then I click the "Description" link
    And I wait for 1 second
    And I should see a link "Description" pointing to "description+desc"
    And I should not see a link "Description" pointing to "description+asc"
    And page should have "full time" before "internship"
    Then I click the "Description" link
    And I wait for 1 second
    And I should see a link "Description" pointing to "description+asc"
    And I should not see a link "Description" pointing to "description+desc"
    And page should have "internship" before "full time"

    Then I click the "Company" link
    And I wait for 1 second
    And I should see a link "Company" pointing to "job_company_name+desc"
    And I should not see a link "Company" pointing to "job_company_name+asc"
    And page should have "ACME" before "Widgets"
    Then I click the "Company" link
    And I wait for 1 second
    And I should see a link "Company" pointing to "job_company_name+asc"
    And I should not see a link "Company" pointing to "job_company_name+desc"
    And page should have "Widgets" before "ACME"

    Then I click the "Applied" link
    And I wait for 1 second
    And I should see a link "Applied" pointing to "created_at+desc"
    And I should not see a link "Applied" pointing to "created_at+asc"
    Then I click the "Applied" link
    And I wait for 1 second
    And I should see a link "Applied" pointing to "created_at+asc"
    And I should not see a link "Applied" pointing to "created_at+desc"

    Then I click the "Status" link
    And I wait for 1 second
    And I should see a link "Status" pointing to "status+desc"
    And I should not see a link "Status" pointing to "status+asc"
    Then I click the "Status" link
    And I wait for 1 second
    And I should see a link "Status" pointing to "status+asc"
    And I should not see a link "Status" pointing to "status+desc"
