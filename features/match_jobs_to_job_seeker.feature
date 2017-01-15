Feature: Match Jobs to a Job Seeker

  As an Job Developer
  I want to login to PETS
  And find jobs that match a specific Job Seeker resume

  Background: seed data added to database and log in as agency admin

    Given the default settings are present

    Given the following agency people exist:
      | agency  | role      | first_name | last_name | phone        | email                | password  |
      | MetPlus | JD        | Jane       | Developer | 555-111-2222 | jane-dev@metplus.org | qwerty123 |
      | MetPlus | JD,CM     | Mark       | Smith     | 555-111-2222 | mark@metplus.org     | qwerty123 |


    Given the following jobseeker exist:
      | first_name| last_name| email                     | phone       |password  |password_confirmation| year_of_birth |job_seeker_status |
      | John      | Seeker   | john.seeker@gmail.com     | 345-890-7890| password |password             | 1990          |Unemployed Seeking |
      | Tom       | Seeker   | tom.seeker@gmail.com      | 345-890-7890| password |password             | 1990          |Employed Looking   |
      | Mary      | Jones    | mary.jones@gmail.com      | 345-890-7890| password |password             | 1990          |Employed Looking   |

    Given the following resumes exist:
      | file_name          | job_seeker             |
      | Janitor-Resume.doc | john.seeker@gmail.com |

   Given the following agency relations exist:
     | job_seeker            | agency_person        | role |
     | tom.seeker@gmail.com  | mark@metplus.org     | JD   |
     | mary.jones@gmail.com  | mark@metplus.org     | CM   |
     | john.seeker@gmail.com | jane-dev@metplus.org | JD   |

   Given the following companies exist:
     | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
     | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |
     | MetPlus | Hammer Inc.  | hammer.com  | 555-222-4444 | corp@hammer.com  | corp@hammer.com  | 13-3456789 | active |

   Given the following company people exist:
     | company      | role  | first_name | last_name | email            | password  | phone        |
     | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com.com   | qwerty123 | 555-222-3334 |
     | Hammer Inc.  | CA    | Tom        | Hammer    | ca@hammer.com    | qwerty123 | 555-222-4445 |

   Given the following jobs exist:
     | title            | company_job_id  | shift  | fulltime | description                 | company      | creator        |
     | ruby developer   | KRK01K          | Evening| true     | internship position with pay| Widgets Inc. | carter@ymail.com.com |
     | c++ developer    | KRK02K          | Evening| true     | internship position with pay| Widgets Inc. | carter@ymail.com.com |
     | erlang developer | KRK03K          | Evening| true     | internship position with pay| Widgets Inc. | carter@ymail.com.com |
     | hammer expert    | KRK04K          | Evening| true     | internship position with pay| Hammer Inc.  | ca@hammer.com |
     | nailer           | KRK05K          | Evening| true     | internship position with pay| Hammer Inc.  | ca@hammer.com |
     | devops           | KRK06K          | Evening| true     | internship position with pay| Widgets Inc. | carter@ymail.com.com |
     | master developer | KRK07K          | Evening| true     | internship position with pay| Widgets Inc. | carter@ymail.com.com |
     | coffee breaker   | KRK08K          | Evening| true     | internship position with pay| Widgets Inc. | carter@ymail.com.com |
     | doer             | KRK09K          | Evening| true     | internship position with pay| Widgets Inc. | carter@ymail.com.com |
     | breaker          | KRK10K          | Evening| true     | internship position with pay| Hammer Inc.  | ca@hammer.com |

  @javascript
  Scenario: Access job seeker job matching page
    Given I am on the home page
    And I login as "jane-dev@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'jane-dev@metplus.org' Home page
    And I wait 2 seconds
    And I should see "Seeker, John"
    And I should not see "No resume on file"
    Then I press the Job Match button for 'john.seeker@gmail.com'
    And I wait 5 seconds
    And I should be on the Job Seeker 'john.seeker@gmail.com' job match page
    And I should see "2.6 / 5.0" in the same table row as "master developer"

  @javascript
  Scenario: Job Seekers do not have Resumes
    Given I am on the home page
    And I login as "mark@metplus.org" with password "qwerty123"
    And I should be on the Agency Person 'mark@metplus.org' Home page
    And I wait 2 seconds
    And I should see "Seeker, Tom"
    And I should see "No resume on file"
