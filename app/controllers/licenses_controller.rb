class LicensesController < ApplicationController

  before_action :confirm_xhr
  before_action :user_logged!

  def create
    license = License.new(license_params)
    authorize license
    if license.save
      render nothing: true
    else
      render partial: 'shared/error_messages',
                      locals: {object: license}, status: 422
    end
  end

  def show
    authorize License.new
    begin
      license = License.find(params[:id])
    rescue
      render nothing: true, status: 404
    else
      render json: { abbr: license.abbr,
                     title: license.title,
                     id: license.id }
    end
  end

  def update
    authorize License.new
    begin
      license = License.find(params[:id])
    rescue
      render nothing: true, status: 404
    else
      if license.update(license_params)
        render nothing: true
      else
        render partial: 'shared/error_messages',
                        locals: {object: license}, status: 422
      end
    end
  end

  def destroy
    authorize License.new
    begin
      license = License.find(params[:id])
    rescue
      render nothing: true, status: 404
    else
      license.destroy
      render json: { license_count: License.count }
    end
  end

  def license_params
    params.require(:license).permit(:abbr, :title)
  end

  private

  def confirm_xhr
    raise 'Not an XHR request' unless request.xhr?
  end
end
