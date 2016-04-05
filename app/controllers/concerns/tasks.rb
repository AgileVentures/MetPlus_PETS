module Tasks
  extend ActiveSupport::Concern

  def display_tasks
    tasks = Task.paginate(:page => params[:tasks_page], :per_page => 10).find_by_owner_user pets_user
    tasks
  end
end