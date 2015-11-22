class CreateGuestUserIps < ActiveRecord::Migration
  def change
    create_table :guest_user_ips do |t|
      t.string :ip_address
      t.boolean :block, :default => false

      t.timestamps
    end
  end
end
