Feature: View job application status

  As a job seeker person
  I want to view my job application status

Background: data is added to database

  Given the default settings are present

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | Cane       | Daniel    | cane@ymail.com | qwerty123 | 555-222-3334 |

  Given the following jobseekers exist:
    | first_name | last_name | email         | phone        | password  | password_confirmation | year_of_birth | job_seeker_status  |
    | John       | Seeker    | john@mail.com | 345-890-7890 | qwerty123 | qwerty123             | 1990          | Unemployed Seeking |
    | July       | Seeker    | july@mail.com | 345-890-7890 | qwerty123 | qwerty123             | 1990          | Unemployed Seeking |

  Given the following jobs exist:
    | title        | company_job_id | description | company      | creator        | status  |
    | hr assistant | KRK01K         | internship  | Widgets Inc. | cane@ymail.com | filled  |
    | hr associate | KRK02K         | internship  | Widgets Inc. | cane@ymail.com | filled  |

  Given the following job applications exist:
    | job title    | job seeker    | status       |
    | hr assistant | july@mail.com | accepted     |
    | hr associate | july@mail.com | not_accepted |
    | hr associate | john@mail.com | accepted     |

  @javascript
  Scenario: Successful and unsuccessful application for job seeker
    Given I am on the home page
    And I login as "july@mail.com" with password "qwerty123"
    And I wait 1 second
    And I should see my "july@mail.com" application for "hr assistant" was "Accepted"
    Then I click the first "hr assistant" link
    And I should see "hr assistant" show status "filled"
    And I should not see "Click Here To Apply Online"
    Then I return to my "july@mail.com" home page
    And I should see my "july@mail.com" application for "hr associate" was "Not Accepted"
    Then I click the first "hr associate" link
    And I should see "hr associate" show status "filled"
    And I should not see "Click Here To Apply Online"
