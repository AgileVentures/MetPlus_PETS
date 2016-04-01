module TaskManager

  STATUS = ['New', 'Work in progress', 'Done', 'Assigned']

  ## The methods from this module will be available at Class level
  module ClassMethods
    ## Method that will create a task, give an audience(In the format needed by the task), the type and more arguments
    def create_task(audience, task_type, *args)
      person = nil
      job = nil
      company = nil
      args.each do |arg|
        person = arg if arg.is_a? User
        job = arg if arg.is_a? Job
        company = arg if arg.is_a? Company
      end
      task = send("new_#{task_type}".to_sym, audience, person, job, company)

      if not args.include? 'no_events'
        schedule_event :taskCreated, task, :AA
      end
      return task
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^new_(.+)$/
        return new_task $1, *args
      else
        super meth, *args, &block
      end
    end

    # Logic for this method MUST match that of the detection in method_missing
    def respond_to_missing?(method_name, include_private = false)
      method_name =~ /^new_(.+)$/ || super
    end

    ## Method used to schedule a future event, this functionality is not yet defined
    def schedule_event event_type, task, role_to_notify
    end

    ## Method used to unschedule one event, this functionality is not yet defined
    def unschedule_event event_type, task, role_to_notify
    end

    private
    ## Method that will create the task itself
    def new_task task_type, owner, target_user = nil, target_job = nil, target_company = nil
      task = Task.new
      task.task_owner = owner
      task.user = target_user
      task.job = target_job
      task.company = target_company
      task.task_type = task_type
      task.status = STATUS[0]
      task.save
      task
    end

  end

  ## The functions inside this module will not be used they are here just for information
  module InstanceMethods
    private
    def wip_test task
      puts 'wip on my task'
    end
    def done_test task
      puts 'done on my task'
    end
  end

  ## Assign the current task to a specific person
  def assign person
    raise ArgumentError, 'Task need to be in created state' if status != STATUS[0]
    send("assign_#{task_type}".to_sym, self, person)
  end

  ## Change the status of the task to Work In Progress
  def work_in_progress
    raise ArgumentError, 'Task need to be in assigned state' if status != STATUS[3]
    send("wip_#{task_type}".to_sym, self)
  end

  ## Change the status of the task to Complete
  def complete
    raise ArgumentError, 'Task need to be in work in progress state' if status != STATUS[1]
    send("done_#{task_type}".to_sym, self)
  end

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /^wip_(.+)$/
      return TaskManager::wip_default self, *args, &block
    elsif meth.to_s =~ /^done_(.+)$/
      return TaskManager::done_default self, *args, &block
    elsif meth.to_s =~ /^assign_(.+)$/
      return TaskManager::assign_default self, *args, &block
    else
      super meth, *args, &block
    end
  end

  # Logic for this method MUST match that of the detection in method_missing
  def respond_to_missing?(method_name, include_private = false)
    method_name =~ /^(wip|done)_(.+)$/ || super
  end

  private
  # Function that will assign a task to a person
  # Default function called, if no other specific function exists
  def self.assign_default task, person, *args, &block
    task.status = STATUS[3]
    task.task_owner = {:user => person}
    task.save
    if args.size == 1 or args[1] != 'no_events'
      Task.unschedule_event :taskCreated, task, :AA
      Task.schedule_event :taskAssigned, task, :AA
    end
    return task
  end

  # Function that will mark the task as Work in Progress
  # Default function called, if no other specific function exists
  def self.wip_default task, *args, &block
    task.status = STATUS[1]
    task.save
    if args.size == 1 or args[1] != 'no_events'
      Task.unschedule_event :taskAssigned, task, :AA
      Task.schedule_event :taskWorkStarted, task, :AA
    end
    return task
  end

  # Function that will mark the task as Done
  # Default function called, if no other specific function exists
  def self.done_default task, *args, &block
    task.status = STATUS[2]
    task.save
    if args.size == 1 or args[1] != 'no_events'
      Task.unschedule_event :taskWorkStarted, task, :AA
      Task.schedule_event :taskDone, task, :AA
    end
    return task
  end

  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end
end