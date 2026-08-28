class RegistrationsController < ApplicationController
  def new
    redirect_to game_path if logged_in?
    @player = Player.new
  end

  def create
    @player = Player.new(
      first_name: params[:first_name].to_s.strip,
      last_name: params[:last_name].to_s.strip
    )

    if @player.save
      session[:player_id] = @player.id
      redirect_to game_path, notice: "Welcome, #{@player.first_name}!"
    else
      flash.now[:alert] = @player.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end
end
