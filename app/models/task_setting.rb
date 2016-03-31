class TaskSetting < ActiveRecord::Base
  has_many :tasks

  def targets
    @targets.split(',').collect{|target| target.to_sym}
  end

  def task_owners creator
    owners = []
    targets.each do |target|
      if creator.is_a? JobSeeker

      end
    end
    owners
  end
end
