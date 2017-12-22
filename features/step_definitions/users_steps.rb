Given(/^I have the following Job Seekers$/) do |table|
  # table is a table.hashes.keys # => [:email, :password]
  table.hashes.each do |seeker|
    FactoryBot.create(:job_seeker, seeker)
  end
end

Given(/^I activate user "([^"]*)"$/) do |email|
  user = User.find_by_email(email)
  expect(user.activate(user.activation_token)).to be true
end

When(/^I visit profile for "(\w+)"$/) do |first_name|
  user = User.find_by_first_name!(first_name)
  visit "/users/edit.#{user.id}"
end

Then(/^I\sshould\sverify\sthe\schange\sof\sfirst_name\s"(.*?)",\s
       last_name\s"(.*?)"\sand\sphone\s"(.*?)"$/x) do |first_name, last_name, phone|
  user = User.find_by_first_name(first_name)
  expect(user.last_name).to    eql last_name
  expect(user.phone).to        eql phone
end

Then(/^I should( not)? be remembered$/) do |not_remembered|
  cookies = page.driver.cookies
  user_id = cookies['user_id']
  person_type = cookies['person_type']
  if not_remembered
    expect(user_id.expires).to be nil
    expect(person_type.expires).to be nil
  else
    expect(user_id.expires).to be_future
    expect(person_type.expires).to be_future
  end
end

Then(/^I should be logged out$/) do
  cookies = page.driver.cookies
  expect(cookies['person_type']).to be nil
  expect(cookies['user_id']).to be nil
end

Given(/^I have( not)? checked the recaptcha$/) do |not_checked|
  # Override server-side verification of recaptcha response:
  # (the recaptcha widget is being served as a separate document within
  #  an iframe.  There does not seem to be a way to simulate user entry
  #  (checking a box) for the "I'm not a robot" prompt.  This is by design
  #  since the intent is to prevent automated entry that simulates a human.
  # Thus, 1) we won't attempt to "check the box", and 2) we will override
  # server-side verification to just return true (== verified by Google).

  if not_checked
    class RecaptchaService
      def self.verify(_, _)
        false
      end
    end
  else
    class RecaptchaService
      def self.verify(_, _)
        true
      end
    end
  end
end
Then(/^(?:I|they) should( not)? see ("[^"]+"[^"]+"")$/) do |not_see, string|
  if not_see
    assert_no_text(string)
  else
    assert_text(string)
  end
end
