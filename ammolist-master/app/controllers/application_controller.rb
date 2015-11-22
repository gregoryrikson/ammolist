class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_blocked_user

  private
  def check_blocked_user
    if (GuestUserIp.where(:ip_address => request.remote_ip).first.present?) || (spree_current_user.present? && spree_current_user.try(:block).present?)
      redirect_to customs_bloked_user_path
    end
  end
end
