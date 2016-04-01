module TaskManager
  STATUS = ['New', 'Work in progress', 'Done']

  module ClassMethods
  # The JS just got inactive
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
      schedule_event :taskCreated, task, :AA
      return task
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^new_(.+)$/
        return new_task $1, *args
      elsif meth.to_s =~ /^wip_(.+)$/
        return TaskManager::wip self
      else
        super meth, *args, &block
      end
    end

    # Logic for this method MUST match that of the detection in method_missing
    def respond_to_missing?(method_name, include_private = false)
      method_name =~ /^(new|wip|close)_(.+)$/ || super
    end


    def schedule_event event_type, task, role_to_notify
    end

    def unschedule_event event_type, task, role_to_notify
    end

    private
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
  module InstanceMethods
    private
    def wip_test task
      puts 'wip on my task'
    end
    def done_test task
      puts 'done on my task'
    end
  end

  def work_in_progress
    send("wip_#{task_type}".to_sym, self)
  end

  def complete
    send("done_#{task_type}".to_sym, self)
  end

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /^wip_(.+)$/
      return TaskManager::wip_default self
    elsif meth.to_s =~ /^done_(.+)$/
      return TaskManager::done_default self
    else
      super meth, *args, &block
    end
  end

  # Logic for this method MUST match that of the detection in method_missing
  def respond_to_missing?(method_name, include_private = false)
    method_name =~ /^(wip|done)_(.+)$/ || super
  end


  private

  def self.wip_default task
    task.status = STATUS[1]
    task.save
    Task.unschedule_event :taskCreated, task, :AA
    Task.schedule_event :taskWorkStarted, task, :AA
    return task
  end

  def self.done_default task
    task.status = STATUS[2]
    task.save
    Task.unschedule_event :taskWorkStarted, task, :AA
    Task.schedule_event :taskDone, task, :AA
    return task
  end

  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end
end