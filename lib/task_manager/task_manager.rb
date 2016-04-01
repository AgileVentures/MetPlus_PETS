module TaskManager
  STATUS = ['New', 'Work in progress', 'Done']

  # The JS just got inactive
  def new_inactive_js(job_seeker)
    cm = job_seeker.case_manager
    jd = job_seeker.job_developer
    i = 0
    [cm, jd].each do |owner|
      inactive_task = Task.new
      inactive_task.task_owner = owner
      inactive_task.target = job_seeker
      inactive_task.type :InactiveJS
      inactive_task.status = STATUS[0]
      inactive_task.save
      schedule_event(event_inactive_js inactive_task) if i == 0
      i += 1
    end
  end
  # JS or CM started task to send email to JS
  def wip_inactive_js(job_seeker, owner)
    cm = job_seeker.case_manager
    jd = job_seeker.job_developer
    done_inactive_js(job_seeker, cm, false) if owner == jd
    done_inactive_js(job_seeker, jd, false) if owner == cm
    task = Task.find_by :type => :InactiveJS, :task_owner => owner, :target => job_seeker
    task.status = STATUS[1]
    task.save
    schedule_event(event_inactive_js task)
  end
  # Job Seeker as been notified
  def done_inactive_js(job_seeker, owner, sch_event = true)
    task = Task.find_by :type => :InactiveJS, :task_owner => owner, :target => job_seeker
    task.status = STATUS[2]
    schedule_event(event_inactive_js task) if sch_event
  end
  def event_inactive_js task
    case task.status
      when STATUS[0]
        # Generate an event to trigger AA of the agency if is kept for too long in this state
      when STATUS[1]
        # Generate an event to trigger AA of the agency if is kept for too long in this state
      when STATUS[2]
        # Generate an event to trigger inactive user task again after X amount of time
    end
  end

  def task_description task
    case task.type
      when :InactiveJS
        return "Job seeker is inactive!"
    end
  end

  def schedule_event event
  end
end