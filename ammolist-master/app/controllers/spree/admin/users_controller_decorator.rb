module Spree
  module Admin
    class UsersControllerDecorator
      Spree::PermittedAttributes.user_attributes << :block
    end
  end
end
