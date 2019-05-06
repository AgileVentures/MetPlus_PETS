class SkillsController < ApplicationController
  # These actions are designed to respond only to XHR requests

  before_action :confirm_xhr
  before_action :user_logged!

  def create
    params = skill_params
    company_id = params.delete('company_id')
    skill = Skill.new(params)
    skill.organization = Company.find(company_id) if company_id
    authorize skill
    if skill.save
      head :ok
    else
      render partial: 'shared/error_messages',
             locals: { object: skill }, status: 422
    end
  end

  def show
    authorize Skill.new
    begin
      skill = Skill.find(params[:id])
    rescue
      head :not_found
    else
      render json: { name: skill.name,
                     description: skill.description,
                     id: skill.id }
    end
  end

  def update
    authorize Skill.new
    begin
      skill = Skill.find(params[:id])
    rescue
      head :not_found
    else
      update_params = skill_params
      update_params.delete('company_id')
      if skill.update(update_params)
        head :ok
      else
        render partial: 'shared/error_messages',
               locals: { object: skill }, status: 422
      end
    end
  end

  def destroy
    authorize Skill.new
    begin
      skill = Skill.find(params[:id])
    rescue
      head :not_found
    else
      skill.destroy
      render json: { skill_count: Skill.count }
    end
  end

  def skill_params
    params.require(:skill).permit(:name, :description, :company_id)
  end

  private

  def confirm_xhr
    raise 'Not an XHR request' unless request.xhr?
  end
end
