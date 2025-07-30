class AccountActivationsController < ApplicationController
  before_action :load_user, only: %i(edit)
  before_action :validate_activation, only: %i(edit)

  def edit
    @user.activate
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user, status: :see_other
  end

  private

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".user_not_found")
    redirect_to root_path, status: :see_other
  end

  def validate_activation
    return if !@user.activated? && @user.authenticated?(:activation,
                                                        params[:id])

    flash[:danger] = t(".invalid_activation_link")
    redirect_to root_path
  end
end
