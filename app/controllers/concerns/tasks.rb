module Tasks
  extend ActiveSupport::Concern

  def display_tasks task_type, per_page = 10
    case task_type
      when 'mine-open'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_owner_user_open pets_user
      when 'mine-closed'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_owner_user_closed pets_user
      when 'mine-assignable'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_owner_user_assignable pets_user
       when 'agency-new'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_agency_new pets_user
      when 'agency-all'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_agency_active pets_user
      when 'company-open'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_company_open pets_user
      when 'company-closed'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_company_closed pets_user  
    end
  end
end