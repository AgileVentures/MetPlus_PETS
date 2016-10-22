module TaskManager
  module BusinessLogic
  ##
  ## Module that contain all the business logic associated with tasks
  ##
  ## For each new task we need to:
  ## 1 - Add a description of the task to DESCRIPTIONS hash
  ## 2 - Add a hash to ASSIGNABLE_LIST, using the same key as for the description
  ##     above, which in turn has a hash with values for keys:
  ##        type: value is a symbol for the type of entity containing the
  ##              task "audience" (:agency or :company)
  ##        function: value is the name of class method - for the entity defined
  ##                  by :type - that will return an array of "audience" people.
  ## 3 - Create a method inside ClassMethods module called new_[name]_task
  ##      where name is a descriptive name of the new task.  Inside that method,
  ##      call create_task method with three arguments:
  ##        i.   A hash specifying the entity type (:agency or :company), and the
  ##             person role of the audience within that entity,
  ##        ii.  The symbol for the task used in the above two steps, and,
  ##        iii. The "target" for the task - that is, the object of the
  ##             task action (Person, Company, or Job instance)
  ##
  ##
  ## If we need to overload the assign method for the event "my_event"
  ## 1 - Add a function in InstanceMethods called that looks like this:
  ##     def assign_my_event person
  ##         assign_default person, 'no_events'
  ##         # your code here
  ##     end
  ##   The 'no_events' tell the function to not set events for this specific task.
  ##   Remove that if you want an event to be set, or you can set the event for this task in this method.
  ##
  ## If we need to overload the work_in_progress method for the event "my_event"
  ## 1 - Add a function in InstanceMethods called that looks like this:
  ##     def wip_my_event task
  ##         wip_default task 'no_events'
  ##         # your code here
  ##     end
  ##   The 'no_events' tell the function to not set events for this specific task.
  ##   Remove that if you want an event to be set, or you can set the event for this task in this method.
  ##
  ## If we need to overload the complete method for the event "my_event"
  ## 1 - Add a function in InstanceMethods called that looks like this:
  ##     def done_my_event task
  ##         done_default task 'no_events'
  ##         # your code here
  ##     end
  ##   The 'no_events' tell the function to not set events for this specific task.
  ##   Remove that if you want an event to be set, or you can set the event for this task in this method.
  ##

    extend ActiveSupport::Concern

    DESCRIPTIONS = {:need_job_developer => 'Job Seeker has no assigned Job Developer',
                    :need_case_manager  => 'Job Seeker has no assigned Case Manager',
                    :company_registration => 'Review company registration',
                    :job_application => 'Review job application'}
    ASSIGNABLE_LIST = {:need_job_developer => {type: :agency, function: :job_developers},
                       :need_case_manager => {type: :agency, function: :case_managers},
                       :company_registration => {type: :agency, function: :agency_admins},
                       :job_application => {type: :company, function: :everyone}}

    module ClassMethods
      def new_js_registration_task jobseeker, agency
        [new_js_unassigned_jd_task(jobseeker, agency),
         new_js_unassigned_cm_task(jobseeker, agency)]
      end
      def new_js_unassigned_jd_task jobseeker, agency
        create_task({:agency => {agency: agency, role: :AA}}, :need_job_developer, jobseeker)
      end
      def new_js_unassigned_cm_task jobseeker, agency
        create_task({:agency => {agency: agency, role: :AA}}, :need_case_manager, jobseeker)
      end
      def new_review_company_registration_task company, agency
        create_task({:agency => {agency: agency, role: :AA}}, :company_registration, company)
      end
      def new_review_job_application_task job, company
        create_task({:company => {company: company, role: :CA}}, :job_application, job)
      end
    end
    module InstanceMethods

    end

    def description
      DESCRIPTIONS[task_type.to_sym]
    end

    def assignable_list
      return [] unless owner.nil?
      info = ASSIGNABLE_LIST[task_type.to_sym]
      if info[:type] == :agency
        return Agency.send info[:function], task_owner[0].agency
      elsif info[:type] == :company
        return Company.send info[:function], task_owner[0].company
      end
      nil
    end

    private
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end
