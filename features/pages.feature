Feature: a user clicking contact is verified by a recaptcha

  As prospective user of PETS
  I want to make contact and send a message
  
@javascript
Scenario: make contact and check the recaptcha
  Given I am on the home page
  And I click the first "Contact" link
  And I fill in "Full Name" with "Charlie Bucket"
  And I fill in "Email" with "cb@gmail.commetplus.org"
  And I fill in "Message" with "Hi Metplus"
  And I have checked the recaptcha
  And I click the "Send Message" button
  And I wait 2 seconds
  Then I should see "Your message was sent successfully!"

@javascript
Scenario: attempt to make contact without checking the recaptcha
  Given I am on the home page
  And I click the first "Contact" link
  And I fill in "Full Name" with "Charlie Bucket"
  And I fill in "Email" with "cb@gmail.commetplus.org"
  And I fill in "Message" with "Hi Metplus"
  And I have not checked the recaptcha
  And I click the "Send Message" button
  And I wait 1 second
  Then I should see "Please prove to us that you're not a bot"
