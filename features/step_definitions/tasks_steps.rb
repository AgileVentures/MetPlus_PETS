Then(/^I press the (.+) button of the task (\d+)$/) do |button, task|
  step %{I click the "#{button}-#{task}" link}
end

Then(/^The (?:task|tasks) ((\d+,?)+) (?:is|are)( not)? present/) do |tasks, _, not_see|
  tasks.split(/,/).each do |task_id|
    error = false
    begin
      find("#task-#{task_id}")
      error = true if not_see
    rescue Exception => e
      raise "Task with id #{task_id} could not be found" unless not_see
    end
    raise "Task with id #{task_id} is present when it shouldn't be" if error
  end
end

And(/The task (\d+) status is "([^"]+)"$/) do |task_id, status|
  expect(find("#task-#{task_id}-status")).to have_content(status)
end