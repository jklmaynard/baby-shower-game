class CreatePlayerAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :player_answers do |t|
      t.references :player, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string :answer_text
      t.boolean :is_correct, default: false

      t.timestamps
    end

    add_index :player_answers, [ :player_id, :question_id ], unique: true
  end
end
