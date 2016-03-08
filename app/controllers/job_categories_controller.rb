class JobCategoriesController < ApplicationController
  def create
    jc = JobCategory.new(category_params)
    if jc.save
      render nothing: true
    else
      render partial: 'shared/error_messages',
                      locals: {object: jc}, status: 422
    end
  end

  def update
  end

  def category_params
    params.require(:job_category).permit(:name, :description)
  end
end
