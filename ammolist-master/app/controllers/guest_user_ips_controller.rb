class GuestUserIpsController < ApplicationController

  def index
    @guest_ips = GuestUserIp.all.created_at_desc
    @guest_ips = GuestUserIp.where(:ip_address => params[:ip_address]) if params[:ip_address].present?
  end

  def destroy
    respond_to do |format|
      format.html { redirect_to "/admin/users" }
      format.js { 
        @guest_ip = GuestUserIp.where(:id => params[:id]).first
        return redirect_to "/admin/users", error: 'Guest user ip was not found.' if @guest_ip.blank?
        @guest_ip.delete ? flash[:success] = "Guest Ip was deleted successfully." : flash[:error] = @guest_ip.errors.full_messages.join("<br/>").html_safe
      }
    end
  end

  def block_guest
    flash[:error_message] = nil;
    params[:ip_address].blank? ? (flash[:error_message] = 'Please provide Ip Address.') : (GuestUserIp.find_or_create_by(:ip_address => params[:ip_address]) && flash[:success] = "Ip Address was blocked successfull.")
    @guest_ips = GuestUserIp.all.created_at_desc if params[:ip_address].present?
  end

end
