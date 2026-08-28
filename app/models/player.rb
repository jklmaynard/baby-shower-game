class Player < ApplicationRecord
  has_many :player_answers, dependent: :destroy
  has_many :answered_questions, through: :player_answers, source: :question

  validates :first_name, :last_name, presence: true

  def display_name
    "#{first_name} #{last_name[0]&.upcase}."
  end

  def score(total_questions)
    correct = player_answers.where(is_correct: true).count
    "#{correct}/#{total_questions}"
  end
end
