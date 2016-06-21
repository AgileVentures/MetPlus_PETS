Feature: Search Jobs

As a PETS user
I want to search available jobs by various criteria

Background: adding jobs data to DB

	Given the following agencies exist:
		| name    | website     | phone        | email                  | fax          |
		| MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

	Given the following companies exist:
		| agency  | name         | website     | phone        | email            | ein        | status |
		| MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |
		| MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | 12-3456788 | Active |

	Given the following company roles exist:
		| role  |
		| CA    |
		| CC    |

	Given the following company people exist:
		| company      | role  | first_name | last_name | email            | password  | phone        |
		| Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 | 555-222-3334 |
		| Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 | 555-222-3334 |
		| Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |

	Given the following job skills exist:
		| name       | description                            |
		| Skill1     | Topo planning for construction         |
		| Skill2     | Promote tourism for region or location |
		| Skill3     | Long haul driver with Class C license  |

	Given the following jobs exist:
		| title | description | company      | creator          | shift   | skills         | city  |
		| Job1  | About job1. | Widgets Inc. | jane@widgets.com | Day     | Skill1, Skill2 | city1 |
		| Job2  | About job2. | Widgets Inc. | ca@widgets.com   | Day     | Skill3         | city2 |
		| Job3  | About job3. | Feature Inc. | ca@widgets.com   | Evening | Skill1, Skill3 | city3 |
		| Job4  | About job4. | Feature Inc. | ca@widgets.com   | Evening |                | city4 |


@javascript
Scenario: Go to jobs search page, see all jobs, search by title
	Given I am on the home page
	And I click the "Jobs" link
	And I click the "Search Jobs" button
  And I wait 1 second
	Then I should see "Job1"
	And I should see "Job2"
	And I should see "Job3"
	And I should see "Job4"
	And I click the "Show Search Form" link
	Then I should see "Title contains any"
	And I fill in "Title contains any" with "Job1 Job3"
	And I click the "Search Jobs" button
  And I wait 1 second
	Then I should see "Job1"
	And I should see "Job3"
	And I should not see "Job2"
	And I should not see "Job4"

@javascript
Scenario: Search by description
	Given I am on the home page
	And I click the "Jobs" link
	And I click the "Search Jobs" button
	And I click the "Show Search Form" link
	And I fill in "Description contains any" with "Job1., Job3."
	And I click the "Search Jobs" button
	Then I should see "Job1"
	And I should see "Job3"
	And I should not see "Job2"
	And I should not see "Job4"

@javascript
Scenario: Search by skills
	Given I am on the home page
	And I click the "Jobs" link
	And I click the "Search Jobs" button
	And I click the "Show Search Form" link
	And I select "Skill1" in select list "Skills"
	And I select "Skill3" in select list "Skills"
	And I click the "Search Jobs" button
	Then I should see "Job1"
	And I should see "Job3"
	And I should see "Job2"
	And I should not see "Job4"

@javascript
Scenario: Search by city
	Given I am on the home page
	And I click the "Jobs" link
	And I click the "Search Jobs" button
	And I click the "Show Search Form" link
	And I select "city1" in select list "City"
	And I select "city4" in select list "City"
	And I click the "Search Jobs" button
	Then I should see "Job1"
	And I should see "Job4"
	And I should not see "Job2"
	And I should not see "Job3"

@javascript
Scenario: Search by title and description
	Given I am on the home page
	And I click the "Jobs" link
	And I click the "Search Jobs" button
	And I click the "Show Search Form" link
	And I fill in "Title contains all" with "Job4"
	And I fill in "Description contains any" with "Job1., Job2, Job3."
	And I click the "Search Jobs" button
	Then I should not see "Job1"
	And I should not see "Job3"
	And I should not see "Job2"
	And I should not see "Job4"
	And I click the "Show Search Form" link
	And I fill in "Title contains all" with "Job1"
	And I click the "Search Jobs" button
	Then I should see "Job1"
	And I should not see "Job3"
	And I should not see "Job2"
	And I should not see "Job4"
