class AddBlockFieldToUser < ActiveRecord::Migration
  def up
    add_column :spree_users, :block, :boolean, :default => false
  end

  def down
    remove_column :spree_users, :block
  end
end
