class CreateSpreeQuestions < ActiveRecord::Migration
  def change
    create_table :spree_questions do |t|
      t.integer :product_id
      t.integer :user_id
      t.text :content
      t.boolean :is_visible, default: false

      t.timestamps
    end
    add_index :spree_questions, :product_id
  end
end
