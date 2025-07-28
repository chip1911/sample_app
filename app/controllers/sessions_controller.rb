class SessionsController < ApplicationController
  # GET /login
  def new; end

  # POST /login
  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      handle_successful_login user
    else
      flash.now[:danger] = t(".invalid_email_or_password")
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end
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
  redirect_to forwarding_url || user
end
