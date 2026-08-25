class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.text :body, null: false
      t.integer :question_type, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.jsonb :answers, null: false, default: []

      t.timestamps
    end

    add_index :questions, :position
  end
end
