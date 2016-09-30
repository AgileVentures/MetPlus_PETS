class SkillsController < ApplicationController
  # These actions are designed to respond only to XHR requests

  before_action :confirm_xhr
  before_action :user_logged!

  def create
    skill = Skill.new(skill_params)
    authorize skill
    if skill.save
      render nothing: true
    else
      render partial: 'shared/error_messages',
                      locals: {object: skill}, status: 422
    end
  end

  def show
    authorize Skill.new
    begin
      skill = Skill.find(params[:id])
    rescue
      render nothing: true, status: 404
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
      render nothing: true, status: 404
    else
      if skill.update(skill_params)
        render nothing: true
      else
        render partial: 'shared/error_messages',
                        locals: {object: skill}, status: 422
      end
    end
  end

  def destroy
    authorize Skill.new
    begin
      skill = Skill.find(params[:id])
    rescue
      render nothing: true, status: 404
    else
      skill.destroy
      render json: { skill_count: Skill.count }
    end
  end

  def skill_params
    params.require(:skill).permit(:name, :description)
  end

  private

  def confirm_xhr
    raise 'Not an XHR request' unless request.xhr?
  end

end
