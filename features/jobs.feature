Feature: Manage Jobs

As a company person or job developer
I want to create, update, and delete jobs

Background: seed data added to database and log in as agency admim

	Given the default settings are present

	Given the following agency roles exist:
		| role  |
		| AA    |
		| CM    |
		| JD    |

	Given the following agency people exist:
    | agency  | role      | first_name | last_name | phone        | email                | password  |
    | MetPlus | AA,CM,JD  | John       | Smith     | 555-111-2222 | aa@metplus.org       | qwerty123 |
    | MetPlus | JD        | Jane       | Developer | 555-111-2222 | jane-dev@metplus.org | qwerty123 |

	Given the following company roles exist:
    | role  |
    | CA    |
    | CC    |

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |
    | MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | 12-3456788 | Active |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
    | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |
    | Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |


@selenium
Scenario: Company Person Creating, Updating, and Deleting Job successfully and unsuccessfully
	Given I am on the home page
	And I login as "jane@widgets.com" with password "qwerty123"
	When I click the "Post jobs" link
	And I wait 1 second
	And I fill in the fields:
		| Title                  | cashier|
		| Job id                 | KARK12 |
		| Description            | At least two years work experience|
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then I should see "cashier has been created successfully."

	When I click the "jobs-edit-link" link
	And I fill in the fields:
		| Title                  | cab-driver|
		| Job id                 | KRT123 |
		| Description            | Atleast two years work experience|
	And  I select "Day" in select list "Shift"
	Then I check "Fulltime"
	And I press "Update"
	Then I should see "cab-driver has been updated successfully."
	And I should verify the change of title "cab-driver", shift "Day" and jobId "KRT123"

	When I click the "Return To Jobs" link
	And I click the "delete" button
	And I wait 1 second
	Then I should see a popup with the following job information
	And I wait 1 second
	And I click the "modal-delete-id" link
	And I wait 2 seconds
	Then I should see "cab-driver has been deleted successfully."

	And I am on the Job edit page with given record:
	And  I fill in the fields:
		| Title                  | cashier|
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "edit-job-submit"
	Then  I should see "The form contains 2 errors"

	When I click the "Post jobs" link
	And  I fill in the fields:
		| Title                  |  |
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "The form contains 3 errors"
	And I logout


@selenium
Scenario: Job Developer Creating, Updating, and Deleting Job successfully and unsuccessfully
	Given I am on the home page
	And I login as "jane-dev@metplus.org" with password "qwerty123"
	And the Widgets, Inc. company name with address exist in the record
	When I click the "Post jobs" link
	And I wait 1 second
	And I fill in the fields:
		| Title                  | cashier|
	And  I select "Widgets, Inc." in select list "Company Name"
	And I fill in the fields:
		| Job id                 | KARK12 |
		| Description            | Atleast two years work experience|
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then I should see "cashier has been created successfully."


	And I am on the Job edit page with given record:
	And  I fill in the fields:
		| Title                  | cashier|
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "edit-job-submit"
	Then  I should see "The form contains 2 errors"

	When I click the "Post jobs" link
	And  I fill in the fields:
		| Title                  |  |
	And  I select "Widgets, Inc." in select list "Company Name"
	And I fill in the fields:
		| Job id                 |  |
		| Description            |  |
	And  I select "Day" in select list "Shift"
	And  I check "Fulltime"
	And  I press "new-job-submit"
	Then  I should see "The form contains 3 errors"
