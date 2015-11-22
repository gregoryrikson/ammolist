class CreateConstraintTypes < ActiveRecord::Migration
  def change
    create_table :spree_constraint_types do |t|
      t.string :name
      t.string :variant_column_name
      t.string :unit

      t.timestamps
    end
  end
end
