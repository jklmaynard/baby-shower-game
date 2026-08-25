class SessionsController < ApplicationController
  def destroy
    session.delete(:player_id)
    redirect_to new_registration_path
  end
end
