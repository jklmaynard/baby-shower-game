class Player < ApplicationRecord
  has_secure_password :passkey, validations: false

  has_many :player_answers, dependent: :destroy
  has_many :answered_questions, through: :player_answers, source: :question

  validates :first_name, :last_name, presence: true
  validates :passkey_digest, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
