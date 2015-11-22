class AddImageToSpreeQuestions < ActiveRecord::Migration
  def change
    add_column :spree_questions, :image, :string
  end
end
