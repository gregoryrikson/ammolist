class AddMunireusaIdToSpreeVariant < ActiveRecord::Migration
  def change
    add_column :spree_variants, :munireusa_product_id, :integer
  end
end
