module BusinessLogic

  DESCRIPTIONS = {:need_job_developer => 'Job Seeker have no assigned Job Developer',
                  :need_case_manager  => 'Job Seeker have no assigned Case Manager'}

  module ClassMethods
    def new_js_registration_task jobseeker, agency
      [new_js_unassigned_jd_task(jobseeker, agency),
       new_js_unassigned_cm_task(jobseeker, agency)]
    end
    def new_js_unassigned_jd_task jobseeker, agency
      create_task({:agency => {agency: agency, role: :JD}}, :need_job_developer, jobseeker)
    end
    def new_js_unassigned_cm_task jobseeker, agency
      create_task({:agency => {agency: agency, role: :CM}}, :need_case_manager, jobseeker)
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