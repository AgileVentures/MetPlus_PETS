Feature: Associate skills with jobs

As a company person or job developer
I want add or delete skills in a job definition

Background: adding job to database

	Given the default settings are present

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |
    | MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | 12-3456788 | Active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
    | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |
    | Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |

  Given the following jobs exist:
    | title               | company_job_id | shift  | fulltime | description    | company      | creator        |
    | software developer  | JOB01         | Day    | true     | build apps     | Widgets Inc. | ca@widgets.com |
    | dish washer         | JOB02         | Morning| true     | wash dishes    | Widgets Inc. | ca@widgets.com |
    | project manager     | JOB03         | Evening| true     | manage projects| Widgets Inc. | ca@widgets.com |

  Given the following job skills exist:
    | name       | description                            |
    | Skill1     | Topo planning for construction         |
    | Skill2     | Promote tourism for region or location |
    | Skill3     | Long haul driver with Class C license  |

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
  And I select "Skill1" in select list "job[job_skills_attributes][0][skill_id]"
  And I check "Required:"
	And  I press "new-job-submit"
	# Then I should see "cashier has been created successfully."
