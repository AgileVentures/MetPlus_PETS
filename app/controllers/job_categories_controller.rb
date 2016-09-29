class JobCategoriesController < ApplicationController

  before_action :user_logged!

  def create
    category = JobCategory.new(category_params)
    authorize category
    if category.save
      render nothing: true
    else
      render partial: 'shared/error_messages',
                      locals: {object: category}, status: 422
    end
  end

  def show
    authorize JobCategory.new
    begin
      category = JobCategory.find(params[:id])
    rescue
      render nothing: true, status: 404
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
    authorize JobCategory.new
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
    params.require(:job_category).permit(:name, :description)
  end
end
