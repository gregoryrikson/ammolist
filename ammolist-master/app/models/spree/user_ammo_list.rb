module Spree
  class UserAmmoList < Spree::Base
    if Spree.user_class
      belongs_to :user, class_name: Spree.user_class.to_s
    else
      belongs_to :user
    end 
  end
end
