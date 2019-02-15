Then(/^I press the (.+) button of the task (\d+)$/) do |button, task|
  step %(I click the "#{button}-#{task}" link)
end

Then(/^the (?:task|tasks) ((\d+,?)+) (?:is|are)( not)? present/) do |tasks, not_see|
  tasks.split(/,/).each do |task_id|
    error = false
    begin
      find("#task-#{task_id}")
      error = true if not_see
    rescue StandardError
      raise "Task with id #{task_id} could not be found" unless not_see
    end
    raise "Task with id #{task_id} is present when it shouldn't be" if error
  end
end

Then(/^the (?:task|tasks) ((\d+,?)+) (?:is|are) hidden/) do |tasks|
  tasks.split(/,/).each do |task_id|
    begin
      find("#task-#{task_id}", visible: false)
    rescue StandardError
      raise "Hidden task with id #{task_id} could not be found" unless not_see
    end
  end
end

And(/the task (\d+) status is "([^"]+)"$/) do |task_id, status|
  expect(find("#task-#{task_id}-status")).to have_content(status)
end
