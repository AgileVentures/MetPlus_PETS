module Tasks
  extend ActiveSupport::Concern

  def display_tasks task_type, per_page = 10
    case task_type
      when 'mine-open'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_owner_user_open pets_user
      when 'mine-closed'
        return Task.paginate(:page => params[:tasks_page], :per_page => per_page).find_by_owner_user_closed pets_user
    end
  end
end