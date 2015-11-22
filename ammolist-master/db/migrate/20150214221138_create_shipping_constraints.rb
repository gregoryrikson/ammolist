class CreateShippingConstraints < ActiveRecord::Migration
  def change
    create_table :spree_shipping_constraints do |t|
      t.belongs_to :shipping_method
      t.belongs_to :constraint_type
      t.integer :min_value
      t.integer :max_value

      t.timestamps
    end
  end
end
