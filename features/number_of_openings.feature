Feature: Number of openings on a specific job
  As a Company Person
  I want to be able to create a job opening
  So that I can hire multiple people for the same position

Background: Company person is logged in
  
  Given the default settings are present

  Given the following agency people exist:
    | agency  | role  | first_name | last_name | email            | password  |
    | MetPlus | JD    | Jane       | Jones     | jane@metplus.org | qwerty123 |

  Given the following companies exist:
    | agency  | name         | website     | phone        | email          | job_email      | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
    | title               | company_job_id  | description                 | company      | creator          | available_positions | remaining_positions |
    | software developer  | KRK01K          | internship position with pay| Widgets Inc. | carter@ymail.com | 2                   | 2                   |

  Given the following jobseekers exist:
    | first_name | last_name | email                 | phone        | password  | year_of_birth | job_seeker_status  |
    | John       | Seeker    | john.seeker@gmail.com | 345-890-7890 | password  | 1990          | Unemployed Seeking |
    | June       | Seeker    | june@ymail.com        | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |
    | Jane       | Seeker    | jane@ymail.com        | 345-890-7890 | qwerty123 | 1990          | Unemployed Seeking |

  Given the following job applications exist:
    | job title          | job seeker            | status  |
    | software developer | john.seeker@gmail.com | active  |
    | software developer | june@ymail.com        | active  |
    | software developer | jane@ymail.com        | active  |

  Given tasks exist for "john.seeker@gmail.com" and "jane@ymail.com" applications to "Widgets Inc."
  Given I am on the home page
  And I login as "carter@ymail.com" with password "qwerty123"

  Scenario: Company person should see a text field of available positions when creating a job
    When I press "Post Job" within "all-jobs-pane"
    Then I sould see a text field "Available Positions" with the value set to 1

  Scenario: Should see the number of selected positions when creating a new job
    Given I am creating a Job
    And I fill in "Available Positions" with "2"
    When I submit the new job
    Then I should see "Available positions:"
    And I should see "2 of 2 positions available"

  @javascript
  Scenario: Number of available positions should decrease when a job seeker is accepted
    When I accept "jane@ymail.com" for "software developer" with 2 opportunities left
    And I go to the "software developer" job page
    Then I should not see "filled"
    And I should see "1 of 2 positions available"
    Then I should not see "Not Accepted"
    And the task to review "jane@ymail.com" application should be closed

  @javascript
  Scenario: Reject applications if number of available positions reachs zero
    When I accept "june@ymail.com" for "software developer" with 1 opportunity left
    And I go to the "software developer" job page
    Then I should see "0 of 2 positions available"
    And I should see "filled"
    Then I should see "john.seeker@gmail.com" application for "software developer" changes to not_accepted
    And the task to review "john.seeker@gmail.com" application should be closed

  Scenario: Should update available positions field correctly after an edit
    When I go to the "software developer" job page
    And I press "Edit Job"
    Then I sould see a text field "Available Positions" with the value set to 2
    When I fill in "Available Positions" with "3"
    And I fill in job details
    And I press "Update"
    Then I should see "3 of 3 positions available"
