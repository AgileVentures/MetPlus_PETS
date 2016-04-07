Then(/^I press the (.+) button of the task (\d+)$/) do |button, task|
  step %{I am press "#{button}-#{task}"}
end