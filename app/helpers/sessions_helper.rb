module SessionsHelper
  # Set session_token and user-id in the session.
  def log_in user
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= user_from_session || user_from_cookies
  end

  def logged_in?
    !current_user.nil?
  end

  def remember user
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget user
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget current_user
    reset_session
    @current_user = nil
  end

  def current_user? user
    current_user == user
  end

  # Stores the get URL before user login.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  private

  def user_from_session
    return unless (user_id = session[:user_id])

    user = User.find_by(id: user_id)
    user if user&.session_token == session[:session_token]
  end

  def user_from_cookies
    return unless (user_id = cookies.encrypted[:user_id])

    user = User.find_by(id: user_id)
    return unless user&.authenticated?(:remember, cookies[:remember_token])

    log_in user
    user
  end
end
