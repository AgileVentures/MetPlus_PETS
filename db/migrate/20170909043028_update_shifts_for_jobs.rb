class UpdateShiftsForJobs < ActiveRecord::Migration
  def change
    Job.all.each do |j|
      case j.shift
      when 'Morning'
        shift = JobShift.find_or_create_by(shift: 'Morning')
      when 'Day'
        shift = JobShift.find_or_create_by(shift: 'Day')
      when 'Evening'
        shift = JobShift.find_or_create_by(shift: 'Afternoon')
      end

      j.job_shifts = [shift]
    end

    remove_column :jobs, :shift
  end
end
