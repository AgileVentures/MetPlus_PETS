class AgencyAdminController < ApplicationController
  before_action :user_logged!

  def home
    if Agency.this_agency(current_user).nil?
      flash[:notice] = 'Current agency cannot be determined'
      redirect_to(root_path) && return
    end
    @agency = Agency.includes([:agency_people,
                               companies: [:addresses],
                               branches: [:address]])
                    .find(Agency.this_agency(current_user).id)
    check_authorization(@agency)
    @agency_admins = Agency.agency_admins(@agency)
    @branches      = @agency.branches.order(:code)
                            .page(params[:branches_page]).per_page(10)
    @agency_people = @agency.agency_people.joins(:user).order('users.last_name')
                            .page(params[:people_page]).per_page(10)
    @companies     = @agency.companies.order(:name)
                            .page(params[:companies_page]).per_page(10)

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
    check_authorization(Agency.this_agency(current_user))

    if request.xhr?
      case params[:data_type]
      when 'job_categories'
        @job_categories = JobCategory.order(:name)
                                     .page(params[:job_categories_page]).per_page(10)

        render partial: 'job_specialties', object: @job_categories,
               locals: { data_type: 'job_categories',
                         partial_id: 'job_categories_table',
                         show_property_path: :job_category_path,
                         delete_property_path: :job_category_path }
      when 'skills'
        @skills = Skill.includes(:jobs).order(:name)
                       .page(params[:skills_page]).per_page(10)

        render partial: 'shared/job_skills', object: @skills,
               locals: { data_type: 'skills',
                         partial_id: 'skills_table',
                         show_property_path: :skill_path,
                         delete_property_path: :skill_path }
      when 'licenses'
        @licenses = License.includes(:jobs).order(:abbr)
                           .page(params[:licenses_page]).per_page(10)

        render partial: 'shared/licenses', object: @licenses,
               locals: { data_type: 'licenses',
                         partial_id: 'licenses_table',
                         show_property_path: :license_path,
                         delete_property_path: :license_path }
      else
        raise "Do not recognize data type: #{params[:data_type]}"
      end
    else
      @job_categories = JobCategory.order(:name)
                                   .page(params[:job_categories_page]).per_page(10)

      @skills = Skill.includes(:jobs).order(:name)
                     .page(params[:skills_page]).per_page(10)

      @licenses = License.includes(:jobs).order(:abbr)
                         .page(params[:licenses_page]).per_page(10)
    end
  end

  private

  def check_authorization(agency)
    self.action_description = "administer #{agency.name} agency"
    authorize agency, :update?
  end
end
