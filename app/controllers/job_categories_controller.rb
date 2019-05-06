class JobCategoriesController < ApplicationController
  before_action :user_logged!

  def create
    category = JobCategory.new(category_params)
    authorize category
    if category.save
      head :ok
    else
      render partial: 'shared/error_messages',
             locals: { object: category }, status: 422
    end
  end

  def show
    authorize JobCategory.new
    begin
      category = JobCategory.find(params[:id])
    rescue
      head :not_found
    else
      render json: { name: category.name,
                     description: category.description,
                     id: category.id }
    end
  end

  def update
    authorize JobCategory.new
    begin
      category = JobCategory.find(params[:id])
    rescue
      head :not_found
    else
      if category.update(category_params)
        head :ok
      else
        render partial: 'shared/error_messages',
               locals: { object: category }, status: 422
      end
    end
  end

  def destroy
    authorize JobCategory.new
    begin
      category = JobCategory.find(params[:id])
    rescue
      head :not_found
    else
      category.delete
      render json: { job_category_count: JobCategory.count }
    end
  end

  def category_params
    params.require(:job_category).permit(:name, :description)
  end
end
