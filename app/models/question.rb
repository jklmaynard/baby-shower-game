class Question < ApplicationRecord
  enum :question_type, { multiple: 0, blank: 1, date: 2 }

  has_many :player_answers, dependent: :destroy

  validates :body, presence: true
  validates :question_type, presence: true
  validates :answers, presence: true

  default_scope { order(:position, :id) }

  def correct_answers
    answers.select { |a| a["is_correct"] }
  end

  def correct_answer_texts
    correct_answers.map { |a| a["text"] }
  end
end
