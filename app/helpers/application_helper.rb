module ApplicationHelper
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
  
end
