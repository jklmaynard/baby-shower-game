class PlayerAnswer < ApplicationRecord
  belongs_to :player
  belongs_to :question

  validates :player_id, uniqueness: { scope: :question_id, message: "has already answered this question" }
end
