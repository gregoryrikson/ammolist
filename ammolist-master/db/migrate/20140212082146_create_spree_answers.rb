class CreateSpreeAnswers < ActiveRecord::Migration
  def change
    create_table :spree_answers do |t|
      t.integer :question_id
      t.integer :user_id
      t.text :content

      t.timestamps
    end
    add_index :spree_answers, :question_id
  end
end
