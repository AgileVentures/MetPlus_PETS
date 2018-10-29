Feature: Search Jobs

As a PETS user
I want to search available jobs by various criteria

Background: adding jobs data to DB

  Given the following agencies exist:
    | name    | website     | phone        | email                  | fax          |
    | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

  Given the following companies exist:
    | agency  | name         | website     | phone        | email            | job_email        | ein        | status |
    | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@ymail.com   | corp@ymail.com   | 12-3456789 | active |
    | MetPlus | Feature Inc. | feature.com | 555-222-3333 | corp@feature.com | corp@feature.com | 12-3456788 | active |
    | MetPlus | Acme Inc.    | acme.com    | 555-222-3333 | corp@acme.com    | corp@acme.com    | 12-3456787 | active |
    | MetPlus | Inact Inc.   | inact.com   | 555-222-3333 | corp@ia.com      | corp@ia.com      | 12-3456786 | inactive |

  Given the following company roles exist:
    | role  |
    | CA    |
    | CC    |

  Given the following company people exist:
    | company      | role  | first_name | last_name | email            | password  | phone        |
    | Widgets Inc. | CA    | John       | Smith     | carter@ymail.com | qwerty123 | 555-222-3334 |
    | Widgets Inc. | CC    | Jane       | Smith     | jane@ymail.com   | qwerty123 | 555-222-3334 |
    | Feature Inc. | CA    | Charles    | Daniel    | ca@feature.com   | qwerty123 | 555-222-3334 |
    | Acme Inc.    | CA    | Barry      | Nichols   | bn@acme.com      | qwerty123 | 555-222-3334 |
    | Inact Inc.   | CA    | Bruce      | Oswald    | bn@ia.com        | qwerty123 | 555-222-3334 |

  Given the following job skills exist:
    | name       | description                            |
    | Skill1     | Topo planning for construction         |
    | Skill2     | Promote tourism for region or location |
    | Skill3     | Long haul driver with Class C license  |

  Given the following jobs exist:
    | title | description | company      | creator          | skills         | city  |status   |
    | Job1  | About job1. | Widgets Inc. | jane@ymail.com   | Skill1, Skill2 | city1 | active  |
    | Job2  | About job2. | Widgets Inc. | carter@ymail.com | Skill3         | city2 | active  |
    | Job3  | About job3. | Feature Inc. | carter@ymail.com | Skill1, Skill3 | city3 | active  |
    | Job4  | About job4. | Feature Inc. | carter@ymail.com | | city4 | active  |
    | Job5  | About job5. | Feature Inc. | carter@ymail.com | Skill2         | city3 | filled  |
    | Job6  | About job6. | Widgets Inc. | jane@ymail.com   | Skill3         | city1 | revoked |
    | Job7  | About job7. | Inact Inc.   | bn@ia.com        | | city1 | revoked |

@javascript
Scenario: search jobs
  # search by title
  Given I am on the home page
  And I click the "Jobs" link
  And I wait 1 second
  Then I should see "Show Search Form"
  And I should see "Job1"
  And I should see "Job2"
  And I should see "Job3"
  And I should see "Job4"
  Then I click the "Show Search Form" link
  And I wait 1 second
  Then "Title contains any" should be visible
  Then I click the "Hide Search Form" link
  And I wait 1 second
  Then "Title contains all" should not be visible

@javascript
Scenario: Go to jobs search page, see all jobs, search by title
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Show Search Form" link
  And I wait 1 second
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
  And I click the "Show Search Form" link
  And I wait 1 second
  # search by description
  Then I fill in "Title contains any" with ""
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
  And I click the "Show Search Form" link
  And I wait 1 second
  # search by skills
  Then I fill in "Description contains any" with ""
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
  And I click the "Show Search Form" link
  And I wait 1 second
  # search by city
  And I select "city1" in select list "City"
  And I select "city3" in select list "City"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job3"
  And I should not see "Job2"
  And I should not see "Job4"

@javascript
Scenario: Search by title and description
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Show Search Form" link
  And I wait 1 second
  And I fill in "Title contains all" with "Job4"
  And I fill in "Description contains any" with "Job1., Job2, Job3."
  And I click the "Search Jobs" button
  Then I should not see "Job1"
  And I should not see "Job3"
  And I should not see "Job2"
  And I should not see "Job4"
  And I click the "Show Search Form" link
  And I wait 1 second
  And I fill in "Title contains all" with "Job1"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should not see "Job3"
  And I should not see "Job4"
  And I should not see "Job2"

@javascript
Scenario: Search by company
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Show Search Form" link
  And I wait 1 second
  # search by company
  And I select "Widgets Inc." in select list "Company"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job2"
  And I should not see "Job3"
  And I should not see "Job4"
  And I click the "Show Search Form" link
  And I wait 1 second
  Then "Acme Inc." should not be an option for select list "Company"
  And "Inact Inc." should not be an option for select list "Company"
  Then I select "Feature Inc." in select list "Company"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job2"
  And I should see "Job3"
  And I should see "Job4"
  
@javascript
Scenario: Search by status
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Show Search Form" link
  And I wait 1 second
  # search by status
  And I select "filled" in select list "Status"
  And I click the "Search Jobs" button
  Then I should see "Job5"
  And I should not see "Job1"
  And I should not see "Job2"
  And I should not see "Job3"
  And I should not see "Job4"
  And I should not see "Job6"
  And I click the "Show Search Form" link
  And I wait 1 second
  Then I select "revoked" in select list "Status"
  And I click the "Search Jobs" button
  Then I should see "Job5"
  And I should see "Job6"
  And I should not see "Job1"
  And I should not see "Job2"
  And I should not see "Job3"
  And I should not see "Job4"

@javascript
Scenario: Only list jobs of a specific
  Given I am on the home page
  And I login as "carter@ymail.com" with password "qwerty123"
  And I click the "Jobs" link
  Then I should not see "Job3"

  And I click the "Show Search Form" link
  And I should not see "Company" in the search form