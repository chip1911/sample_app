class SessionsController < ApplicationController
  # GET /login
  def new; end

  # POST /login
  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      reset_session
      log_in user
      redirect_to user
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
