class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  # DELETE /microposts/:id
  def destroy
    if @micropost.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".fail")
    end
    redirect_to request.referer || root_url
  end

  # POST /microposts
  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      handle_success_save
    else
      handle_failure_save
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit(Micropost::MICROPOST_PERMIT)
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t(".not_found")
    redirect_to request.referer || root_url
  end

  def handle_success_save
    flash[:success] = t(".success")
    redirect_to root_url
  end

  def handle_failure_save
    @pagy, @feed_items = pagy current_user.feed, items: Settings.page_10,
    limit: Settings.page_10
    render Settings.static_pages_home, status: :unprocessable_entity
  end
end
