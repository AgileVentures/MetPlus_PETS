module TaskManager
  module TaskManager

    extend ActiveSupport::Concern

    STATUS = {NEW: 'New',
              WIP: 'Work in progress',
              DONE: 'Done',
              ASSIGNED: 'Assigned'}

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
      def new_task task_type, owner, target_person = nil, target_job = nil, target_company = nil
        task = Task.new
        task.task_owner = owner
        task.person = target_person
        task.job = target_job
        task.company = target_company
        task.task_type = task_type
        task.status = STATUS[:NEW]
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
      raise ArgumentError, 'Task need to be in created state' if status != STATUS[:NEW]
      send("assign_#{task_type}".to_sym, self, person.pets_user)
    end

    ## Change the status of the task to Work In Progress
    def work_in_progress
      raise ArgumentError, 'Task need to be in assigned state' if status != STATUS[:ASSIGNED]
      send("wip_#{task_type}".to_sym, self)
    end

    ## Change the status of the task to Complete
    def complete
      raise ArgumentError, 'Task need to be in work in progress state' if status != STATUS[:WIP]
      send("done_#{task_type}".to_sym, self)
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^wip_(.+)$/
        return TaskManager::wip_default *args, &block
      elsif meth.to_s =~ /^done_(.+)$/
        return TaskManager::done_default *args, &block
      elsif meth.to_s =~ /^assign_(.+)$/
        return TaskManager::assign_default *args, &block
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
      task.status = STATUS[:ASSIGNED]
      task.task_owner = {:user => person}
      task.save!
      if args.size == 1 or args[1] != 'no_events'
        Task.unschedule_event :taskCreated, task, :AA
        Task.schedule_event :taskAssigned, task, :AA
      end
      return task
    end

    # Function that will mark the task as Work in Progress
    # Default function called, if no other specific function exists
    def self.wip_default task, *args, &block
      task.status = STATUS[:WIP]
      task.save!
      if args.size == 1 or args[1] != 'no_events'
        Task.unschedule_event :taskAssigned, task, :AA
        Task.schedule_event :taskWorkStarted, task, :AA
      end
      return task
    end

    # Function that will mark the task as Done
    # Default function called, if no other specific function exists
    def self.done_default task, *args, &block
      task.status = STATUS[:DONE]
      task.save!
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
end
