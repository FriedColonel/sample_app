class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      user_activated? user
    else
      flash.now[:danger] = t(".invalid")
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def accept user
    log_in user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end

  def user_activated? user
    if user.activated?
      accept user
    else
      flash[:warning] = t ".warning"
      redirect_to root_url
    end
  end
end
