class PasswordResetsController < ApplicationController
  before_action :set_user, only: %i(edit update create)
  before_action :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t ".email_sent"
    redirect_to root_path
  end

  def edit; end

  def update
    if params[:user][:password].blank?
      @user.errors.add(:password, t(".empty_password"))
      render :edit
    elsif @user.update user_params
      log_in @user
      flash[:success] = t ".password_reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    email = params.dig(:password_reset, :email) || params[:email]
    @user = User.find_by email: email.downcase
    return if @user

    flash.now[:danger] = t ".not_found"
    render :new
  end

  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset, params[:id])

    flash.now[:danger] = t ".not_found"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".expired"
    redirect_to new_password_reset_url
  end
end
