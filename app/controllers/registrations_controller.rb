class RegistrationsController < ApplicationController
  def new
    redirect_to game_path if logged_in?
    @player = Player.new
  end

  def create
    unless correct_passkey?(params[:passkey])
      @player = Player.new(first_name: params[:first_name], last_name: params[:last_name])
      flash.now[:alert] = "Invalid passkey. Please check with the game host."
      render :new, status: :unprocessable_entity and return
    end

    @player = Player.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      passkey: params[:passkey]
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
