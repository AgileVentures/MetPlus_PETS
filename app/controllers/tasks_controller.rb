class TasksController < ApplicationController
  include Tasks

  before_action :user_logged!

  def index
    authorize Task.new
    @task_type_t1 = 'mine-open'
    @task_type_t2 = 'agency-new'
    @task_type_t3 = 'mine-closed'
    @render_modal = true
    @tasks_t1 = display_tasks @task_type_t1
    @tasks_t2 = display_tasks @task_type_t2
    @tasks_t3 = display_tasks @task_type_t3
  end

  def assign
    raise 'Unsupported request' if not request.xhr?
    return render(json: { :message => 'Missing assigned target' }, status: 403) if params[:to].nil?

    task = Task.find_by_id params[:id]
    return render json: { :message => 'Cannot find the task!' }, status: 403 if task.nil?

    user = User.find_by_id params[:to]
    return render json: { :message => 'Cannot find user!' }, status: 403 if user.nil?
    return render json: { :message => 'Cannot assign the task to that user!' }, status: 403 \
            if not task.assignable_list.include? user.pets_user

    authorize task
    begin
      task.assign user
    rescue Exception => e
      return render json: { :message => e.message }, status: 500
    end
    return render json: { :message => 'Task assigned' }
  end

  def in_progress
    raise 'Unsupported request' if not request.xhr?

    task = Task.find_by_id params[:id]
    return render json: { :message => 'Cannot find the task!' }, status: 403 if task.nil?

    authorize task
    begin
      task.work_in_progress
    rescue Exception => e
      return render json: { :message => e.message }, status: 500
    end
    render json: { :message => 'Task work in progress' }
  end

  def done
    raise 'Unsupported request' if not request.xhr?

    task = Task.find_by_id params[:id]
    return render json: { :message => 'Cannot find the task!' }, status: 403 if task.nil?

    authorize task
    begin
      task.complete
    rescue Exception => e
      return render json: { :message => e.message }, status: 500
    end
    render json: { :message => 'Task finished' }
  end

  def tasks
    raise 'Unsupported request' if not request.xhr?

    authorize Task.new

    @task_type = params[:task_type] || 'mine-open'

    @render_modal = params[:modal]
    @tasks = display_tasks @task_type

    render partial: 'tasks', :locals => { all_tasks: @tasks, task_type: @task_type }
  end

  def list_owners
    raise 'Unsupported request' if not request.xhr?

    term = params[:q] || {}
    term = term['term'] || ''
    term = term.downcase
    task = Task.find_by_id params[:id]
    return render json: { :message => 'Cannot find the task!' }, status: 403 if task.nil?

    authorize task

    list_users = []
    all_users = task.assignable_list
    return render json: { :message => 'There are no users you can assign this task to!' }, status: 403 \
          if all_users.nil? or all_users.size == 0

    all_users.each do |user|
      if user.full_name.downcase =~ /#{term}/
        list_users << { id: user.user.id, text: user.full_name }
      end
    end
    render json: { :results => list_users }
  end
end
