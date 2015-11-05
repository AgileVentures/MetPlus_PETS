module ApplicationHelper
  def flash_to_css key
    case key
      when 'success'
        'alert-success'
      when 'error'
        'alert-danger'
      when 'info'
        'alert-info'
      when 'warning'
        'alert-warning'
    end
  end
end
