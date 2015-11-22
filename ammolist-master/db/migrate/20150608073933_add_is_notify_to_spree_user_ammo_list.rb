class AddIsNotifyToSpreeUserAmmoList < ActiveRecord::Migration
  def change
    add_column :spree_user_ammo_lists, :is_notified, :boolean, :null => false, :default => false
  end
end
