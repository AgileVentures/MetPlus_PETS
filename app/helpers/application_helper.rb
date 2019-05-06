module ApplicationHelper
  include StarsRenderer

  def status_desc(entity)
    # Converts entitie's status to descriptive string suitable for display
    entity.status.titleize
  end

  def full_title(page_title = '')
    base_title = current_agency.name
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def flash_to_css(key)
    bootstrap_alert_classes.fetch(key, "alert-#{key}")
  end

  def bootstrap_alert_classes
    { 'notice' => 'alert-success', 'alert' => 'alert-danger' }
  end

  def single_line_address(address)
    if address
      "#{address.street}, #{address.city}, #{address.state} #{address.zipcode}"
    else
      'No Address'
    end
  end

  def text_modal_button(button_text, target_div_id, btn_class = 'btn btn-warning btn-xs')
    haml_tag('button', button_text, class: btn_class,
                                    data: { toggle: 'modal',
                                            target: "\##{target_div_id}" })
  end

  def show_person_path(person)
    return job_seeker_path person if person.job_seeker?
    return agency_person_path person if person.is_a? AgencyPerson
    return company_person_path person if person.is_a? CompanyPerson
  end

  def show_person_home_page_path(person)
    return root_path if person.nil?
    return home_job_seeker_path person if person.job_seeker?
    return home_company_person_path person if person.is_a? CompanyPerson
    return home_agency_person_path person if person.is_a? AgencyPerson

    root_path
  end

  def show_stars(rating)
    render_stars(rating)
  end

  # Returns a string of option tags for a 'select' element.
  # The select element allows the user to select the number of items to
  # appear on each pagination page.
  ITEMS_COUNT = [['10', 10], ['25', 25], ['50', 50], %w[All All]].freeze

  def paginate_count_options(count = 10)
    # 'count' is the currently-selected items count.
    options_for_select(ITEMS_COUNT, count)
  end
end
