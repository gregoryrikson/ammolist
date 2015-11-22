class AddAmmunitionIdToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :ammunition_id, :integer
  end
end
