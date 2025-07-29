class PasswordResetsController < ApplicationController
  before_action :load_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :validate_email, only: [:create]

  def new; end

  def edit; end

  # POST /password_resets
  # create password_reset, password_reset_digest, and send email
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t ".email_sent"
    redirect_to root_url, status: :see_other
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, t(".empty"))
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      @user.forget
      reset_session
      log_in @user
      flash[:success] = t(".success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def validate_email
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    return if @user

    flash.now[:danger] = t(".not_found")
    render :new, status: :unprocessable_entity
  end

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".not_found")
    redirect_to root_url, status: :see_other
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t(".in_activated")
    redirect_to root_url, status: :see_other
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".expired")
    redirect_to new_password_reset_url, status: :see_other
  end

  def get_user
    @user = User.find_by email: params[:email]&.downcase
    return if @user

    flash.now[:danger] = t(".not_found")
    render :new, status: :unprocessable_entity
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
