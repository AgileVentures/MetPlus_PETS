class AgencyAdminController < ApplicationController
  def home
    # Cancancan before_filter here .....

    @agency = Agency.includes([ :agency_people,
                              companies: [:addresses],
                               branches: [:address] ]).
                        find(Agency.this_agency(current_user).id)

    @agency_admins = Agency.agency_admins(@agency)
    @branches      = @agency.branches.page(params[:branches_page]).per_page(10)
    @agency_people = @agency.agency_people.page(params[:people_page]).per_page(10)
    @companies     = @agency.companies.page(params[:companies_page]).per_page(10)

    if request.xhr?
      case params[:data_type]
      when 'branches'
        render :partial => 'branches/branches'
      when 'people'
        render :partial => 'agency_people/agency_people'
      when 'companies'
        render :partial => 'companies/companies'
      end
    end
  end

  def job_properties
    if request.xhr?
      case params[:data_type]
      when 'job_categories'
        @job_categories = JobCategory.order(:name).
                    page(params[:job_categories_page]).per_page(10)

        render partial: 'job_properties', object: @job_categories,
                locals: {data_type:  'job_categories',
                         partial_id: 'job_categories_table',
                         edit_property_path:   :edit_job_category_path,
                         delete_property_path: :job_category_path}
      when 'skills'
        @skills = Skill.order(:name).
                    page(params[:skills_page]).per_page(10)

        render partial: 'job_properties', object: @skills,
                locals: {data_type:  'skills',
                         partial_id: 'skills_table',
                         edit_property_path:   :edit_skill_path,
                         delete_property_path: :skill_path}
      else
        raise "Do not recognize data type: #{params[:data_type]}"
      end
    else
      @job_categories = JobCategory.order(:name).
                  page(params[:job_categories_page]).per_page(10)

      @skills = Skill.order(:name).
                  page(params[:skills_page]).per_page(10)
    end
  end
end
