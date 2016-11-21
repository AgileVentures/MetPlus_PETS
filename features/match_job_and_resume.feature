Feature: Match a Job to a Job Seeker's Résumé

  As an Job Seeker
  When I view a job
  I want to see how well my resume matches that job

  Background: seed data added to database

    Given the default settings are present

    Given the following jobseeker exist:
      | first_name| last_name| email                  | phone       |password  |password_confirmation| year_of_birth |job_seeker_status |
      | John      | Seeker   | john.seeker@gmail.com  | 345-890-7890| password |password             | 1990          |Unemployed Seeking |

    Given the following resumes exist:
      | file_name          | job_seeker            |
      | Janitor-Resume.doc | john.seeker@gmail.com |

   Given the following companies exist:
     | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
     | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | corp@widgets.com | 12-3456789 | active |

   Given the following company people exist:
     | company      | role  | first_name | last_name | email            | password  | phone        |
     | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |

   Given the following jobs exist:
     | title            | company_job_id| shift| fulltime | description| company      | creator        |
     | ruby developer   | KRK01         | Day  | true     | internship | Widgets Inc. | ca@widgets.com |
     | java developer   | KRK02         | Day  | true     | internship | Widgets Inc. | ca@widgets.com |
     | c++ developer    | KRK03         | Day  | true     | internship | Widgets Inc. | ca@widgets.com |
     | node developer   | KRK04         | Day  | true     | internship | Widgets Inc. | ca@widgets.com |

  @javascript
  Scenario: Match job to resume
    Given I am on the home page
    And I login as "john.seeker@gmail.com" with password "password"
    Then I should see "Signed in successfully"
    Then I click the "Jobs" link
    And I should see "ruby developer"
    Then I click the "ruby developer" link
    And I wait 1 second
    And I should see "Match against my Résumé"
    Then I click the "Match against my Résumé" link
    And I wait 2 seconds
    Then I should see "Job match against your résumé"
    And I should see "1.3 stars"
    Then I click the "Close" button
    Then I click the "Jobs" link
    And I wait 1 second
    And I should see "c++ developer"
    Then I click the "c++ developer" link
    And I wait 1 second
    And I should see "Match against my Résumé"
    Then I click the "Match against my Résumé" link
    And I wait 2 seconds
    Then I should see "Job match against your résumé"
    And I should see "4.4 stars"
