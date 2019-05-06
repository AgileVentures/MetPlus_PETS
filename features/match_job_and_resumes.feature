Feature: Match a Job to a Job Seeker's Résumé

  As an Job Seeker
  When I view a job
  I want to see how well my resume matches that job

  Background: seed data added to database

    Given the default settings are present

    Given the following jobseekers exist:
      | first_name| last_name| email                  | phone       |password  | year_of_birth |job_seeker_status |
      | John      | Seeker   | john.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Jane      | Seeker   | jane.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Joan      | Seeker   | joan.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Jonn      | Seeker   | jonn.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Adam      | Seeker   | adam.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Sean      | Seeker   | sean.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Myna      | Seeker   | myna.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Chet      | Seeker   | chet.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |
      | Paul      | Seeker   | paul.seeker@gmail.com  | 345-890-7890| password | 1990          |Unemployed Seeking |

    Given the following resumes exist:
      | file_name          | job_seeker            |
      | Janitor-Resume.doc | john.seeker@gmail.com |
      | Janitor-Resume.doc | jane.seeker@gmail.com |
      | Janitor-Resume.doc | joan.seeker@gmail.com |
      | Janitor-Resume.doc | jonn.seeker@gmail.com |
      | Janitor-Resume.doc | adam.seeker@gmail.com |
      | Janitor-Resume.doc | sean.seeker@gmail.com |
      | Janitor-Resume.doc | myna.seeker@gmail.com |
      | Janitor-Resume.doc | chet.seeker@gmail.com |
      | Janitor-Resume.doc | paul.seeker@gmail.com |

    Given the following companies exist:
     | agency  | name         | website     | phone        | email          | job_email      | ein        | status |
     | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

    Given the following company people exist:
     | company      | role  | first_name | last_name | email            | password  | phone        |
     | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com | qwerty123 | 555-222-3334 |

    Given the following jobs exist:
     | title            | company_job_id| description| company      | creator        |
     | ruby developer   | KRK01         | internship | Widgets Inc. | carter@ymail.com |
     | java developer   | KRK02         | internship | Widgets Inc. | carter@ymail.com |

    Given the following job applications exist:
     | job title      | job seeker            |
     | ruby developer | john.seeker@gmail.com |

    Given the following agency people exist:
     | agency  | role  | first_name | last_name | email              | password  | phone        |
     | MetPlus | JD    | Mike       | Check     | mike@metplus.org   | qwerty123 | 555-222-3334 |
     | MetPlus | JD    | Joseph     | Jobber    | joseph@metplus.org | qwerty123 | 555-222-3334 |

    Given the following agency relations exist:
     | job_seeker            | agency_person      | role |
     | john.seeker@gmail.com | mike@metplus.org   | JD   |
     | jane.seeker@gmail.com | joseph@metplus.org | JD   |

  @email
  @javascript
  Scenario: match job to my resume(s)

    # Job seeker: match job to my résumé
    Given I am on the home page
    And I login as "john.seeker@gmail.com" with password "password"
    Then I should see "Signed in successfully"
    Then I click the "Jobs" link
    And I should see "ruby developer"
    Then I click the "ruby developer" link
    And I wait 1 second
    And I should see "Match against my Résumé"
    Then I click the "#match_my_resume" react link
    Then I accept the confirm dialog
    And I wait 2 seconds
    Then I should see "Job match against your résumé"
    And I should see "1.3 stars"
    Then I click the "Close" button
    Then I click the "Jobs" link
    And I wait 1 second
    And I should see "java developer"
    Then I click the "java developer" link
    And I wait 1 second
    And I should see "Match against my Résumé"
    Then I click the "#match_my_resume" react link
    Then I accept the confirm dialog
    And I wait 2 seconds
    Then I should see "Job match against your résumé"
    And I should see "3.1 stars"

    # Job developer: match job to job seekers
    And I click the "Hello, John" link
    Then I logout
    And I am logged in as "carter@ymail.com" with password "qwerty123"
    Then I should see "Signed in successfully"
    Then I click the "ruby developer" link
    And I wait 1 second
    And I should see "Match all job seekers"
    Then I click the "Match all job seekers" link
    Then I accept the confirm dialog
    And I wait 4 seconds
    Then I should see "Job Seeker matches for job: ruby developer"
    And I should see "Seeker, John"
    And I should see "Mike Check"

    # Company person: contact job developer for job seeker
    Then I am on the Company Person 'carter@ymail.com' Home page
    Then I click the "ruby developer" link
    And I wait 1 second
    Then I click the "Match all job seekers" link
    Then I accept the confirm dialog
    And I wait 2 seconds
    Then I should see "Job Seeker matches for job: ruby developer"
    And I should see "Joseph Jobber"
    Then I click the "Joseph Jobber" link
    Then I accept the confirm dialog
    And I wait 1 second
    Then I should see notification "Notified job developer"
