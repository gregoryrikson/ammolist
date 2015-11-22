class CreateUserSubscriptions < ActiveRecord::Migration
  def change
    create_table :spree_user_subscriptions do |t|
      t.string :email,        :null => false
      t.belongs_to :user
      t.string :confirmation_code
      t.boolean :is_confirmed, :null => false, :default => false
      t.boolean :is_subscribed, :null => false, :default => true

      t.timestamps
    end
  end
end
