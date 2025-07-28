class SessionsController < ApplicationController
  before_action :check_login, only: %i(create)
  before_action :check_activation, only: %i(create)

  # GET /login
  def new; end

  # POST /login
  def create
    handle_successful_login @user
  end

  # DELETE /logout
  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end

  private

  def handle_successful_login user
    forwarding_url = session[:forwarding_url]
    reset_session
    if params.dig(:session, :remember_me) == Settings.remember_me_status
      remember(user)
    else
      forget(user)
    end
    log_in user
    redirect_to forwarding_url || user, status: :see_other
  end

  def check_login
    @user = User.find_by email: params.dig(:session, :email)&.downcase
    return if @user&.authenticate params.dig(:session, :password)

    flash.now[:danger] = t(".invalid_email_or_password")
    render :new, status: :unprocessable_entity
  end

  def check_activation
    return if @user.activated?

    flash[:warning] = t(".not_activated")
    redirect_to root_path, status: :see_other
  end
end
