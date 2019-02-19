module JobsHelper
  def sort_instruction(count)
    return ' Click on any column title to sort.' if count > 1
  end

  def skills_for_company(company)
    # Return all skills that can be associated with a job for this company.
    # This includes company-specific skills as well as "agency" skills (that is,
    # skills not associated with a particular company)

    Skill.order(:name)
         .where('organization_id = ? OR organization_id IS null', company.id)
  end

  def job_salary_details(job)
    if !job.min_salary.nil?
      details = "Minimum Salary: #{number_to_currency(job.min_salary)}"
      details += ", Maximum Salary: #{number_to_currency(job.max_salary)}" if
                 job.max_salary
      details += ", Pay Period: #{job.pay_period}"
    else
      details = '(not specified)'
    end
    details
  end
end
