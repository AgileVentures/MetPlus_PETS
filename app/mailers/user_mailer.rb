class UserMailer < ApplicationMailer
  def activation user
    @user = user
    mail(
        :subject => 'Welcome to MetPlus',
        :to  => @user.email,
    )
  end
end
