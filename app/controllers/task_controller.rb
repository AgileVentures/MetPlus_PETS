class TaskController < ApplicationController
  include Tasks
  def index
    @tasks = display_tasks
  end

  def assign
    raise 'Unsupported request' if not request.xhr?
    return render( json: {:message => 'Missing assigned target'}, status: 403) if params[:to].nil?
    task = Task.find_by_id params[:id]
    return render json: {:message => 'Cannot find the task!'}, status: 403 if task.nil?
    user = User.find_by_id params[:to]
    return render json: {:message => 'Cannot find user!'}, status: 403 if user.nil?
    return render json: {:message => 'Cannot assign the task to that user!'}, status: 403 \
            if not task.assignable_list.include? user.pets_user
    begin
      task.assign user
    rescue Exception => e
      return render json: {:message => e.message}, status: 500 if user.nil?
    end
    render json: {:message => 'Task assigned'}
  end

  def in_progress
  end

  def done
  end

  def list_owners
    raise 'Unsupported request' if not request.xhr?
    term = params[:q] || {}
    term = term['term'] || ''
    term = term.downcase
    return render json: {:message => 'Cannot find the task!'}, status: 401 if task.nil?
    list_users = []
    all_users = task.assignable_list
    return render json: {:message => 'There are no users you can assign this task to!'}, status: 401 \
          if all_users.nil? or all_users.size == 0
    all_users.each do |user|
      if user.full_name.downcase =~ /#{term}/
        list_users << {id: user.user.id, text: user.full_name}
      end
    end
    render json: {:results => list_users}
  end

end
