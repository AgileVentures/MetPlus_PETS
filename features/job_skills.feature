Feature: Associate skills with jobs

As a company person or job developer
I want add or delete skills in a job definition

Background: adding job to database

	Given the default settings are present

  Given the following companies exist:
    | agency  | name         | website     | phone        | email           | job_email       | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com  | corp@ymail.com  | 12-3456789 | active |
		| MetPlus | Gadgets Inc. | gadgets.com | 555-222-4444 | corp@gadget.com | corp@gadget.com | 12-4567890 | active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com   | qwerty123 | 555-222-3334 |
    | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com | qwerty123 | 555-222-3334 |

  Given the following job skills exist:
    | name       | description                            | organization|
    | Skill1     | Topo planning for construction         |             |
    | Skill2     | Promote tourism for region or location |             |
    | Skill3     | Long haul driver with Class C license  |             |
		| CmpySkill1 | Company-specific skill 1               | Widgets Inc.|
		| CmpySkill2 | Company-specific skill 2               | Widgets Inc.|
		| CmpySkill3 | Company-specific skill 3               | Widgets Inc.|
		| CmpySkill4 | Company-specific skill 4               | Gadgets Inc.|
		| CmpySkill5 | Company-specific skill 5               | Gadgets Inc.|
		| CmpySkill6 | Company-specific skill 6               | Gadgets Inc.|

  Given the following jobs exist:
    | title | description | company      | creator          | skills | city  |
    | Job1  | About job1. | Widgets Inc. | jane@ymail.com   | Skill1 | city1 |
    | Job2  | About job2. | Widgets Inc. | carter@ymail.com | Skill3 | city2 |


@javascript
Scenario: Create job with associated skills
  Given I am on the home page
	And I am logged in as "carter@ymail.com" with password "qwerty123"
	When I click the first "Post Job" link
	And I fill in the fields:
		| Title                  | cashier|
		| Company Job ID         | JOB3   |
		| Description            | Must have experience with POS terminals |
  And I click the "Add Job Skill" link
	And "CmpySkill4" should not be an option for select list "Name"
  And I select "CmpySkill1" in select list "Name"
  And I check "Required"
  And I select "2" in select list "Min years"
  And I select "10" in select list "Max years"
  Then I click the "Add Job Skill" link
  And I select "Skill2" in second select list "Name"
  And I check second "Required"
  And I select "5" in second select list "Min years"
  And I select "12" in second select list "Max years"
	And  I press "Create"
	Then I should see "cashier has been created successfully."
  And I should see "CmpySkill1"
  And I should see "Skill2"

@javascript
Scenario: Edit job and change associated skills
  Given I am on the home page
	And I am logged in as "carter@ymail.com" with password "qwerty123"
  And I click the "Jobs" link
  Then I click the "Job1" link
  And I wait 1 second
  And I should see "Skill1"
  Then I click the "Edit Job" link
  And I wait 1 second
  And I click the first "remove job skill" link
  And I click the "Add Job Skill" link
  And I select "CmpySkill3" in select list "Name"
	And I click the "Add Job Skill" link
	And I select "CmpySkill2" in second select list "Name"
  And  I press "Update"
	Then I should see "Job1 has been updated successfully."
  And I should see "CmpySkill2"
  And I should see "CmpySkill3"
  And I should not see "Skill1"
