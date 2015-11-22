module Spree
  class CustomsController < Spree::StoreController 
    respond_to :html
    layout false
  
    skip_before_filter :check_blocked_user, :only => [:bloked_user, :blocked_guest]

    def bloked_user
      return false
    end

    def blocked_guest
      @guest_ip = GuestUserIp.where(:id => params[:guest_id]).first
      @guest_ip.block = @guest_ip.block ? false : true
      @guest_ip.save
    end
    
  end
end
