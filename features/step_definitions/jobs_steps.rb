Given(/^the following jobs exists:$/) do |table|
  table.hashes.each do |hash|
    @job = Job.create!(hash)
  end
end

