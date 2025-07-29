class StaticPagesController < ApplicationController
  def home
    return unless logged_in?

    @micropost = current_user.microposts.build
    @pagy, @feed_items = pagy current_user.feed.recent_posts
                                          .with_attached_image
                                          .includes(:user),
                              items: Settings.page_10,
                              limit: Settings.page_10
  end

  def help; end

  def contact; end
end
