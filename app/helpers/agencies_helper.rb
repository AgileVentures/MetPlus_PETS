module AgenciesHelper
  def agency_display_name
    unless current_agency.display_name.blank?
      current_agency.display_name
    else
      current_agency.name
    end
  end
end
