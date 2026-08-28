class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_player, :logged_in?

  private

  def current_player
    @current_player ||= Player.find_by(id: session[:player_id]) if session[:player_id]
  end

  def logged_in?
    current_player.present?
  end

  def require_login
    redirect_to new_registration_path, alert: "Please register to play." unless logged_in?
  end
end
