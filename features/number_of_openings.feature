Feature: Number of openings on a specific job
  As a Company Person
  I want to be able to create a job opening
  So that I can hire multiple people for the same position

Background: Company person is logged in
   Given I am logged in as company person
   
 Scenario: Company person should see a text field of available positions when creating a job
   When I press "Post Job" within "all-jobs-pane"
   Then I sould see a text field "Available Positions" with the value set to 1

 Scenario: should see the number of selected positions
   Given I press "Post Job" within "all-jobs-pane"
   And I am creating a Job
   When I select 2 available positions from the dropdown
   And submit the create the new job
   Then I should see "2 of 2 Positions available"

 Scenario: number of available positions should decrease when a job seeker is accepted
   When I accept a Job Seeker for a Job with 2 opportunities
   And I go to the "Developer" job page
   Then I see '1 of 2 Positions available'
   And the task to review the Job Application just accepted, should be closed

 Scenario: Reject applications if number of available positions reachs zero
   When I accept a Job Seeker for a Job with only 1 opportunity left
   Then I visit the job application page
   And I see '0 of 2 Positions available'
   And All the Job Seeker applications should have been rejected
   And all the tasks to review Job Applications for that job should be closed
