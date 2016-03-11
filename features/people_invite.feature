Feature: agency admin logs in and performs admin functions

  As an agency admin
  I want to login to PETS
  And perform various administrative functions

Background: seed data added to database and log in as agency admim

  Given the following agency roles exist:
  | role  |
  | AA    |
  | CM    |
  | JD    |

  Given the following company roles exist:
  | role  |
  | CA    |
  | CC    |

  Given the following agencies exist:
  | name    | website     | phone        | email                  | fax          |
  | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |

  Given the following agency people exist:
  | agency  | role  | first_name | last_name | email            | password  |
  | MetPlus | AA    | John       | Smith     | aa@metplus.org   | qwerty123 |
  | MetPlus | CM    | Jane       | Jones     | jane@metplus.org | qwerty123 |

  Given the following companies exist:
  | agency  | name         | website     | phone        | email            | ein        | status |
  | MetPlus | Widgets Inc. | widgets.com | 555-222-3333 | corp@widgets.com | 12-3456789 | Active |

  Given the following company people exist:
  | company      | role  | first_name | last_name | email            | password  |
  | Widgets Inc. | CA    | John       | Smith     | ca@widgets.com   | qwerty123 |
  | Widgets Inc. | CC    | Jane       | Smith     | jane@widgets.com | qwerty123 |

Scenario: invite (and reinvite) new agency person
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Invite Person" link
  And I should see "Send invitation"
  And I fill in "Email" with "adam@metplus.org"
  And I fill in "First name" with "Adam"
  And I fill in "Last name" with "Powell"
  And I click the "Send an invitation" button
  And I should see "An invitation email has been sent to adam@metplus.org."
  And I should see "Edit Agency Person: Adam Powell"
  And I click the "Cancel" link
  Then I should see "Agency Person"
  And I click the "Invite Again" link
  And I should see "An invitation email has been sent to adam@metplus.org."
  Then "adam@metplus.org" should receive 2 emails with subject "Invitation instructions"
  When "adam@metplus.org" opens the email
  Then they should see "MetPlus has invited you confirm your account in PETS" in the email body

Scenario: agency person accepts invitation in email
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Invite Person" link
  And I fill in "Email" with "adam@metplus.org"
  And I fill in "First name" with "Adam"
  And I fill in "Last name" with "Powell"
  And I click the "Send an invitation" button
  And I should see "An invitation email has been sent to adam@metplus.org."
  And I log out
  Then "adam@metplus.org" should receive 1 email with subject "Invitation instructions"
  When "adam@metplus.org" opens the email
  Then they should see "Accept invitation" in the email body
  And "adam@metplus.org" follows "Accept invitation" in the email
  Then they should see "Set your password"
  And they fill in "Password" with "qwerty123"
  And they fill in "Password confirmation" with "qwerty123"
  And they click the "Set my password" button
  Then they should see "Your password was set successfully. You are now signed in."

Scenario: invite (and reinvite) new Company person
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Widgets Inc." link
  And I click the "Invite Person" link
  And I should see "Send invitation"
  And I fill in "Email" with "newguy@widgets.com"
  And I fill in "First name" with "New"
  And I fill in "Last name" with "Guy"
  And I click the "Send an invitation" button
  And I should see "An invitation email has been sent to newguy@widgets.com."
  And I should see "Edit Company Person: New Guy"
  And I click the "Cancel" link
  Then I should see "Company Person"
  And I click the "Invite Again" link
  And I should see "An invitation email has been sent to newguy@widgets.com."
  Then "newguy@widgets.com" should receive 2 emails with subject "Invitation instructions"
  When "newguy@widgets.com" opens the email
  Then they should see "MetPlus has invited you confirm your account in PETS" in the email body

Scenario: company person accepts invitation in email
  Given I am on the home page
  And I login as "aa@metplus.org" with password "qwerty123"
  Then I should see "Signed in successfully."
  And I should see "Admin"
  And I click the "Admin" link
  And I click the "Agency and Partner Companies" link
  Then I click the "Widgets Inc." link
  Then I click the "Invite Person" link
  And I fill in "Email" with "newguy@widgets.com"
  And I fill in "First name" with "New"
  And I fill in "Last name" with "Guy"
  And I click the "Send an invitation" button
  And I should see "An invitation email has been sent to newguy@widgets.com."
  And I log out
  Then "newguy@widgets.com" should receive 1 email with subject "Invitation instructions"
  When "newguy@widgets.com" opens the email
  Then they should see "Accept invitation" in the email body
  And "newguy@widgets.com" follows "Accept invitation" in the email
  Then they should see "Set your password"
  And they fill in "Password" with "qwerty123"
  And they fill in "Password confirmation" with "qwerty123"
  And they click the "Set my password" button
  Then they should see "Your password was set successfully. You are now signed in."
