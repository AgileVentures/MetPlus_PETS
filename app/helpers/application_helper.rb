module ApplicationHelper

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
      "#{address.street}, #{address.city}, #{address.zipcode}"
    else
      'No Address'
    end
  end

  def text_modal_button(button_text, target_div_id)
    haml_tag('button', button_text,
              class: 'btn btn-warning btn-xs',
              data: {toggle: 'modal', target: "\##{target_div_id}"} )
  end

  def user_type(current_user)
    if current_user.actable_type
      current_user.actable_type.constanize.find(current_user.actable_id)
    else
      current_user
    end
  end

end
