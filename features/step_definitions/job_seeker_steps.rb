Then(/^I should get a download with the filename "([^\"]*)"$/) do |filename|
  expect(page.driver.response_headers['Content-Disposition'])
    .to include("attachment; filename=\"#{filename}\"")
  expect(page.driver.response_headers['Content-Type'])
    .to eq 'application/octet-stream'
end
