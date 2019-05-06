module Tasks
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
  def display_tasks(task_type, per_page = 10)
    collection = nil
    case task_type
    when 'mine-open'
      collection = Task.find_by_owner_user_open pets_user
    when 'mine-closed'
      collection = Task.find_by_owner_user_closed pets_user
    when 'agency-new'
      collection = Task.find_by_agency_new pets_user
    when 'agency-all'
      collection = Task.find_by_agency_active pets_user
    when 'agency-closed'
      collection = Task.find_by_agency_closed pets_user
    when 'company-open'
      collection = Task.find_by_company_open pets_user
    when 'company-new'
      collection = Task.find_by_company_new pets_user
    when 'company-all'
      collection = Task.find_by_company_active pets_user
    when 'company-closed'
      collection = Task.find_by_company_closed pets_user
    end

    return collection if collection.nil?

    collection.paginate(page: params[:tasks_page], per_page: per_page)
  end
  # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
end
