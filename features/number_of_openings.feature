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
  | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com | corp@ymail.com | 12-3456789 | active |

Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  | phone        |
  | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com   | qwerty123 | 555-222-3334 |

Given the following jobs exist:
  | title               | company_job_id  | description                 | company      | creator          | available_positions |
  | software developer  | KRK01K          | internship position with pay| Widgets Inc. | carter@ymail.com | 2                  |

Given the following jobseekers exist:
  | first_name| last_name| email                     | phone       | password   |password_confirmation| year_of_birth |job_seeker_status |
  | John      | Seeker   | john.seeker@gmail.com    | 345-890-7890| password   |password             | 1990          |Unemployed Seeking |

Given the following resumes exist:
  | file_name          | job_seeker            |
  | Janitor-Resume.doc | john.seeker@gmail.com |

Given the following job applications exist:
  | job title          | job seeker             |
  | software developer | john.seeker@gmail.com |

Given I am on the home page
And I login as "carter@ymail.com" with password "qwerty123"
   
 Scenario: Company person should see a text field of available positions when creating a job
   When I press "Post Job" within "all-jobs-pane"
   Then I sould see a text field "Available Positions" with the value set to 1

 Scenario: Should see the number of selected positions
   Given I am creating a Job
   And I fill in "Available Positions" with "2"
   When I submit the new job
   Then I should see "Available positions:"
   And I should see "2 of 2 positions available"

 Scenario: Number of available positions should decrease when a job seeker is accepted
   When I accept "john.seeker@gmail.com" job seeker for "software developer" job with 2 opportunities
   And I go to the "software developer" job page
   Then I see '1 of 2 Positions available'
   And the task to review the Job Application just accepted, should be closed

 Scenario: Reject applications if number of available positions reachs zero
   When I accept a Job Seeker for a Job with only 1 opportunity left
   Then I visit the job application page
   And I see '0 of 2 Positions available'
   And All the Job Seeker applications should have been rejected
   And all the tasks to review Job Applications for that job should be closed
