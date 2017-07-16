class PagesController < ApplicationController
  def about; end

  def contact
    return post_response if request.post?
  end

  private

  def parse_form_data
    @captcha_response = params['g-recaptcha-response']
    @user = {
      full_name: params[:full_name],
      surname: params[:surname],
      email: params[:email]
    }
    @message = params[:message]
    @remote_ip = request.remote_ip
  end

  def post_response
    parse_form_data
    respond_to do |format|
      @verified = captcha_verified?(@captcha_response, @remote_ip)
      ContactMailer.message_received(@user, @message).deliver_later if @verified

      @alert_template = @verified ? 'success_alert' : 'error_alert'
      format.js { render :contact }
    end
  end

  def captcha_verified?(captcha_response, remote_ip)
    RecaptchaService.verify(captcha_response, remote_ip)
  end
end
