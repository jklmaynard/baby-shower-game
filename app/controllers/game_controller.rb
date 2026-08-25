class GameController < ApplicationController
  before_action :require_login

  def index
    @questions = Question.all
    @player = current_player
  end
end
