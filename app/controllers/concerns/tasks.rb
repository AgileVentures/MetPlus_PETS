module Tasks
  extend ActiveSupport::Concern

  def display_tasks task_type, per_page = 10
    case task_type
      when 'mine-open'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_owner_user_open pets_user
      when 'mine-closed'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_owner_user_closed 
       when 'agency-open'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_agency_open pets_user
      when 'agency-closed'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_agency_closed pets_user
      when 'company-open'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_company_open pets_user.agency
      when 'company-closed'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_company_closed pets_user.agency  
    end
  end
end