class GuestUserIp < ActiveRecord::Base

  #SCOPES
  scope :created_at_desc, -> { order("created_at desc") }
end
