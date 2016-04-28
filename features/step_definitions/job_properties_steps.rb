When(/^(?:I|they) drag "([^"]*)" to "([^"]*)"$/) do |prop_name, heading|
  case heading
  when "Skills for this job category"
    skill_ele = find('.draggable', text: prop_name)
    if page.has_selector?('#add_job_category_skills')
      drop_container = find('#add_job_category_skills')
    else
      drop_container = find('#update_job_category_skills')
    end
    skill_ele.drag_to(drop_container)
  when "All Skills"
    skill_ele = find('.droppable').find('div', text: prop_name)
    skill_ele.drag_to(find('.all_skills'))
  else
    raise 'Do not recognize droppable container heading'
  end
end

And(/^(?:I|they) should( not)? see "([^"]*)" under "([^"]*)"$/) do |not_see,
                                                        prop_name, heading|
  case heading
  when "Skills for this job category"
    if page.has_selector?('#add_job_category_skills')
      container = find('#add_job_category_skills')
    else
      container = find('#update_job_category_skills')
    end
    if not_see
      expect(container).not_to have_content(prop_name)
    else
      expect(container).to have_content(prop_name)
    end
  else
    raise 'Do not recognize droppable container heading'
  end
end
