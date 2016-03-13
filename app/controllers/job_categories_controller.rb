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

  def edit
    category = JobCategory.find(params[:id])
    if category
      render json: { name: category.name,
                     description: category.description,
                     id: category.id }
    else
      render nothing: true, status: 404
    end
  end

  def update
    category = JobCategory.find(params[:id])
    if category.update(category_params)
      render nothing: true
    else
      render partial: 'shared/error_messages',
                      locals: {object: category}, status: 422
    end
  end

  def category_params
    params.require(:job_category).permit(:name, :description)
  end
end
