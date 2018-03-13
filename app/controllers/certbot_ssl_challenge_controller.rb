class CertbotSslChallengeController < ApplicationController
  def letsencrypt
    render plain: "#{params[:id]}.#{ENV['CERTBOT_SSL_CHALLENGE']}", layout: false
  end
end