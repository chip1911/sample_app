class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :logged_in_user, only: %i(edit update index)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  # GET /signup
  def new
    @user = User.new
  end

  # GET /users/:id
  def show; end

  # POST /signup
  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t(".check_email")
      redirect_to root_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:id/edit
  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t(".success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /users
  def index
    @pagy, @users = pagy(User.newest, items: Settings.page_10,
    limit: Settings.page_10)
  end

  # DELETE /users/:id
  def destroy
    if @user.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".fail")
    end
    redirect_to users_path, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit(User::USER_PERMIT)
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:warning] = t(".not_found")
    redirect_to root_path
  end

  # Confirm a user is logged in.
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t(".not_logged_in")
    redirect_to login_path, status: :see_other
  end

  def correct_user
    return if current_user?(@user)

    flash[:danger] = t(".not_correct_user")
    redirect_to root_path, status: :see_other
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t(".not_admin")
    redirect_to root_path
  end
end
