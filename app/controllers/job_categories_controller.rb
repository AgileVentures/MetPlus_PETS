class JobCategoriesController < ApplicationController
  def create
    category = JobCategory.new(category_params)
    if category.save
      render nothing: true
    else
      render partial: 'shared/error_messages',
                      locals: {object: category}, status: 422
    end
  end

  def show
    begin
      category = JobCategory.find(params[:id])
    rescue
      render nothing: true, status: 404
    else
      skills_list = category.skills.map do |skill|
        { id: skill.id, name: skill.name }
      end
      render json: { name: category.name,
                     description: category.description,
                     id: category.id,
                     skills: skills_list }
    end
  end

  def update
    begin
      category = JobCategory.find(params[:id])
    rescue
      render nothing: true, status: 404
    else
      if category.update(category_params)
        render nothing: true
      else
        render partial: 'shared/error_messages',
                        locals: {object: category}, status: 422
      end
    end
  end

  def destroy
    begin
      category = JobCategory.find(params[:id])
    rescue
      render nothing: true, status: 404
    else
      category.delete
      render json: { job_category_count: JobCategory.count }
    end
  end

  def category_params
    params.require(:job_category).permit(:name, :description, skill_ids: [])
  end
end
