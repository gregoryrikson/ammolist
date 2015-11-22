class CreateAmmunitions < ActiveRecord::Migration
  def change
    create_table :spree_ammunitions do |t|
      t.string :title
      t.text :body
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :spree_ammunitions
  end
end
