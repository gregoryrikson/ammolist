class DeleteBlockFromGuestUserIp < ActiveRecord::Migration
  def change
    remove_column :guest_user_ips, :block
  end
end
