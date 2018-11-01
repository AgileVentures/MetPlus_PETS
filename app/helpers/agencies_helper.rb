module AgenciesHelper
  def agency_display_name
    if current_agency.display_name.blank?
      current_agency.name
    else
      current_agency.display_name
    end
  end
end
