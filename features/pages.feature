Feature: a user clicking contact is verified by a recaptcha

  As prospective user of PETS
  I want to make contact and send a message

@selenium_browser
Scenario: click the contact link
  Given I am on the home page
  And I click the first "Contact" link
  And I fill in "Full Name" with "Charlie Bucket"
  And I fill in "Email" with "cb@gmail.commetplus.org"
  And I fill in "Message" with "Hi Metplus"
  And I click the recaptcha
  And I click the "Send Message" button
  Then I should see "Your message was sent successfully!"
