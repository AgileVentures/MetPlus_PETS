Feature: Match job developer's job seekers against a job

As a job developer
I want to login to PETS
And match my job seekers against a job

Background: seed data added to database and log in as job developer

  Given the default settings are present

  Given the following agency people exist:
    | agency  | role      | first_name | last_name | phone        | email                | password  |
    | MetPlus | JD        | Jane       | Developer | 555-111-2222 | jane-dev@metplus.org | qwerty123 |
    | MetPlus | JD    | Mark       | Smith     | 555-111-2222 | mark@metplus.org     | qwerty123 |

  Given the following jobseekers exist:
    | first_name| last_name| email                     | phone       |password  |password_confirmation| year_of_birth |job_seeker_status |
    | John      | Seeker   | john.seeker@ymail.com     | 345-890-7890| password |password             | 1990          |Unemployed Seeking |
    | Tom       | Seeker   | tom.seeker@ymail.com      | 345-890-7890| password |password             | 1990          |Employed Looking   |
    | Mary      | Jones    | mary.jones@ymail.com      | 345-890-7890| password |password             | 1990          |Employed Looking   |

  Given the following resumes exist:
    | file_name          | job_seeker             |
    | Janitor-Resume.doc | tom.seeker@ymail.com |

  Given the following agency relations exist:
    | job_seeker            | agency_person        | role |
    | tom.seeker@ymail.com  | mark@metplus.org     | JD   |
    | mary.jones@ymail.com  | mark@metplus.org     | JD   |
    | john.seeker@ymail.com | jane-dev@metplus.org | JD   |

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |
    | MetPlus | Hammer Inc.  | hammer.com  | 555-222-4444 | corp@hammer.com  | corp@hammer.com  | 13-3456789 | active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | ca@ymail.com   | qwerty123 | 555-222-3334 |
    | Hammer Inc.  | CA    | Tom        | Hammer    | ca@hammer.com    | qwerty123 | 555-222-4445 |

  Given the following jobs exist:
    | title            | company_job_id  | description                 |  company      | creator        |
    | ruby developer   | KRK01K          | internship position with pay| Hammer Inc. | ca@hammer.com |

  @javascript
  Scenario: Valid selection of job seekers
    Given I am on the home page
    And I login as "mark@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'mark@metplus.org' Home page
    When I visit the jobs page
    And I click the "ruby developer" link
    And I wait 1 second
    Then I should see "Match your job seekers against job"
    When I click the "Match your job seekers against job" link
    And I select "Seeker, Tom" in select list "job-seekers-select"
    And I select "Jones, Mary" in select list "job-seekers-select"
    And I click the "Run match" button
    And I accept the confirm dialog
    Then I should see "Matching Job Seekers for the job ruby developer"
    And I should see "Seeker, Tom" before "Jones, Mary"
    And I should see "No résumé on file" in the same table row as "Jones, Mary"

  @javascript
  Scenario: Invalid selection of job seekers
    Given I am on the home page
    And I login as "mark@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'mark@metplus.org' Home page
    When I visit the jobs page
    And I click the "ruby developer" link
    And I wait 1 second
    Then I should see "Match your job seekers against job"
    When I click the "Match your job seekers against job" link
    And I wait 1 second
    And I click the "Run match" button
    And I accept the confirm dialog
    Then I should see "Please choose a job seeker"
