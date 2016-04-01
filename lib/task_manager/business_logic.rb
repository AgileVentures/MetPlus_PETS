module BusinessLogic
##
## Module that contain all the business logic associated with tasks
##
## For each new task we need to:
## 1 - Add a description of the task to DESCRIPTIONS hash
## 2 - Create a function inside ClassMethods module called new_[name]_task
##      where name is the descriptive name of the new task
##
##
## If we need to overload the assign method for the event "my_event"
## 1 - Add a function in InstanceMethods called that looks like this:
##     def assign_my_event person
##         assign_default person, 'no_events'
##         # your code here
##     end
##   The 'no_events' tell the function to do not set events for this specific task or if you want to set the events
##   using your code
##
## If we need to overload the work_in_progress method for the event "my_event"
## 1 - Add a function in InstanceMethods called that looks like this:
##     def wip_my_event person
##         wip_default 'no_events'
##         # your code here
##     end
##   The 'no_events' tell the function to do not set events for this specific task or if you want to set the events
##   using your code
##
## If we need to overload the complete method for the event "my_event"
## 1 - Add a function in InstanceMethods called that looks like this:
##     def done_my_event person
##         done_default 'no_events'
##         # your code here
##     end
##   The 'no_events' tell the function to do not set events for this specific task or if you want to set the events
##   using your code
##

  DESCRIPTIONS = {:need_job_developer => 'Job Seeker have no assigned Job Developer',
                  :need_case_manager  => 'Job Seeker have no assigned Case Manager'}

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
  end
  module InstanceMethods

  end

  def description
    DESCRIPTIONS[task_type.to_sym]
  end

  private
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end
end