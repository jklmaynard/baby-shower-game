class LeaderboardController < ApplicationController
  def index
    @total = Question.count
    @players = Player
      .left_joins(:player_answers)
      .select("players.*, COUNT(CASE WHEN player_answers.is_correct = true THEN 1 END) AS correct_count")
      .group("players.id")
      .order("correct_count DESC, players.created_at ASC")
  end
end
