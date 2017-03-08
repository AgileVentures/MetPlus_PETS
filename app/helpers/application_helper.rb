module ApplicationHelper

  include StarsRenderer

  def status_desc entity
    # Converts entitie's status to descriptive string suitable for display
    entity.status.titleize
  end

  def full_title(page_title = '')
    base_title = "MetPlus"
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def flash_to_css key
    case key
      when 'notice'
        'alert-success'
      when 'alert'
        'alert-danger'
      when 'info'
        'alert-info'
      when 'warning'
        'alert-warning'
    end
  end

  def single_line_address(address)
    if address
      "#{address.street}, #{address.city}, #{address.state} #{address.zipcode}"
    else
      'No Address'
    end
  end

  def text_modal_button(button_text, target_div_id, btn_class='btn btn-warning btn-xs')
    haml_tag('button', button_text, class: btn_class,
              data: {toggle: 'modal', target: "\##{target_div_id}"} )
  end

  def show_person_path person
    return job_seeker_path person if person.is_job_seeker?
    return agency_person_path person if person.is_a? AgencyPerson
    return company_person_path person if person.is_a? CompanyPerson
  end

  def show_person_home_page_path person
    return root_path if person.nil?
    return home_job_seeker_path person if person.is_job_seeker?
    return home_company_person_path person if person.is_a? CompanyPerson
    return home_agency_person_path person if person.is_a? AgencyPerson
    root_path
  end

  def show_stars(rating)
    render_stars(rating)
  end

  def paginate(collection, params= {})
    will_paginate collection, params.merge(:renderer => RemoteLinkPaginationHelper::BootstrapLinkRenderer)
  end
end
