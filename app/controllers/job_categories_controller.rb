class JobCategoriesController < ApplicationController
  def create
    if jc = JobCategory.new(category_params).save
      render nothing: true
    else
      render :json => { errors: jc.errors.full_messages,
                        status: :unprocessable_entity }
    end
  end

  def update
  end

  def category_params
    params.require(:job_category).permit(:name, :description)
  end
end
