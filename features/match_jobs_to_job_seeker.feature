Feature: Match Jobs to a Job Seeker

As a Job Developer
I want to login to PETS
And find jobs that matches a specific Job Seeker resume

Background: seed data added to database and log in as agency admin

Given the default settings are present

Given the following agency people exist:
  | agency  | role      | first_name | last_name | phone        | email                | password  |
  | MetPlus | JD        | Jane       | Developer | 555-111-2222 | jane-dev@metplus.org | qwerty123 |
  | MetPlus | JD,CM     | Mark       | Smith     | 555-111-2222 | mark@metplus.org     | qwerty123 |


Given the following jobseekers exist:
  | first_name| last_name| email                  | phone        |password  | year_of_birth | job_seeker_status  |
  | John      | Seeker   | john.seeker@gmail.com  | 345-890-7890 | password | 1990          | Unemployed Seeking |
  | Tom       | Seeker   | tom.seeker@gmail.com   | 345-890-7890 | password | 1990          | Employed Looking   |

Given the following resumes exist:
  | file_name          | job_seeker             |
  | Janitor-Resume.doc | john.seeker@gmail.com |

Given the following agency relations exist:
 | job_seeker            | agency_person        | role |
 | tom.seeker@gmail.com  | mark@metplus.org     | JD   |
 | john.seeker@gmail.com | jane-dev@metplus.org | JD   |

Given the following companies exist:
 | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
 | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com   | corp@ymail.com | 12-3456789 | active |

Given the following jobs exist:
 | title            | company_job_id  | description| company      |
 | ruby developer   | KRK01K          | internship | Widgets Inc. |
 | c++ developer    | KRK02K          | internship | Widgets Inc. |
 | erlang developer | KRK03K          | internship | Widgets Inc. |

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
  And I should see "2.6 / 5.0" in the same table row as "c++ developer"

  # Job seeker has no résumé
  And I click the "Hello, Jane" link
  Then I logout
  And I am logged in as "mark@metplus.org" with password "qwerty123"
  And I should be on the Agency Person 'mark@metplus.org' Home page
  And I wait 2 seconds
  And I should see "Seeker, Tom"
  And I should see "No resume on file"
