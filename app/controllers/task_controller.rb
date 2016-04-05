class TaskController < ApplicationController
  include Tasks
  def index
    @tasks = display_tasks
  end

  def assign
    raise 'Unsupported request' if not request.xhr?
    return render json: {:message => 'Missing assigned target'}, status: 401 if params[:to].nil?
    task = Task.find_by_id params[:id]
    return render json: {:message => 'Cannot find the task!'}, status: 401 if task.nil?
    user = User.find params[:to]
    return render json: {:message => 'Cannot find user!'}, status: 401 if user.nil?
    return render json: {:message => 'Cannot assign the task to that user!'}, status: 401 if  task.assignable_list.include? user.pets_user

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
    task = Task.find_by_id params[:id]
    return render json: {:message => 'Cannot find the task!'}, status: 401 if task.nil?
    list_users = []
    all_users = task.assignable_list
    puts all_users
    return render json: {:message => 'There are no users you can assign this task to!'}, status: 401 \
          if all_users.nil? or all_users.size == 0
    puts 'out'
    all_users.each do |user|
      puts "searching #{user.full_name.downcase} =~ #{term}"
      if user.full_name.downcase =~ /#{term}/
        list_users << {id: user.user.id, text: user.full_name}
      end
    end
    render json: {:results => list_users}
  end
end
