class PasswordResetsController < ApplicationController
  before_action :load_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :validate_email, only: [:create]
  before_action :check_blank_password, only: [:update]

  # GET /password_resets/new
  def new; end

  # GET /password_resets/:id/edit
  def edit; end

  # POST /password_resets
  # create password_reset, password_reset_digest, and send email
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t(".email_sent")
    redirect_to root_path, status: :see_other
  end

  # PATCH /password_resets/:id
  def update
    if @user.update(user_params.merge(reset_digest: nil))
      handle_successful_update
    else
      handle_failed_update
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
    @user = User.find_by email: params[:email]&.downcase
    return if @user

    flash[:danger] = t(".not_found")
    redirect_to root_path, status: :see_other
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t(".in_activated")
    redirect_to root_path, status: :see_other
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".expired")
    redirect_to new_password_reset_path, status: :see_other
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def check_blank_password
    return if params.dig(:user, :password).present?

    @user.errors.add(:password, t(".empty"))
    render :edit, status: :unprocessable_entity
  end

  def handle_successful_update
    @user.forget
    reset_session
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user
  end

  def handle_failed_update
    render :edit, status: :unprocessable_entity
  end
end
