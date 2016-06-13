Feature: Associate skills with jobs

As a company person or job developer
I want add or delete skills in a job definition

Background: adding job to database

	Given the default settings are present

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
    | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |

  Given the following job skills exist:
    | name       | description                            |
    | Skill1     | Topo planning for construction         |
    | Skill2     | Promote tourism for region or location |
    | Skill3     | Long haul driver with Class C license  |

  Given the following jobs exist:
    | title | description | company      | creator          | shift   | skills         | city  |
    | Job1  | About job1. | Widgets Inc. | jane@widgets.com | Day     | Skill1, Skill2 | city1 |
    | Job2  | About job2. | Widgets Inc. | ca@widgets.com   | Day     | Skill3         | city2 |


@javascript
Scenario: Create job with associated skills
  Given I am on the home page
	And I am logged in as "ca@widgets.com" with password "qwerty123"
	When I click the "Post jobs" link
	And I fill in the fields:
		| Title                  | cashier|
		| Job id                 | JOB3   |
		| Description            | Must have experience with POS terminals |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
  And I click the "Add Job Skill" link
  And I select "Skill1" in select list "Name:"
  And I check "Required:"
  And I select "2" in select list "Min years:"
  And I select "10" in select list "Max years:"
  Then I click the "Add Job Skill" link
  And I select "Skill2" in second select list "Name:"
  And I check second "Required:"
  And I select "5" in second select list "Min years:"
  And I select "12" in second select list "Max years:"
	And  I press "Create"
	Then I should see "cashier has been created successfully."
  And I should be on the jobs page
  Then I click the "cashier" link
  And I wait 1 second
  And I should see "Skill1"
  And I should see "Skill2"

@javascript
Scenario: Edit job and change associated skills
  Given I am on the home page
	And I am logged in as "ca@widgets.com" with password "qwerty123"
  And I click the "Jobs" link
  Then I click the "Job1" link
  And I wait 1 second
  And I should see "Skill1"
  And I should see "Skill2"
  Then I click the "Edit Job" link
  And I wait 1 second
  And I click the second "remove job skill" link
  And I click the "Add Job Skill" link
  And I select "Skill3" in second select list "Name:"
  And  I press "Update"
	Then I should see "Job1 has been updated successfully."
  And I should see "Skill1"
  And I should see "Skill3"
  And I should not see "Skill2"
