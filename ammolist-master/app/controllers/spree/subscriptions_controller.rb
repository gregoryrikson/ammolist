module Spree
  class SubscriptionsController < Spree::StoreController
    respond_to :html

    def subscribe
      response_msg = []
      if params[:email].empty?
        response_msg = [ :status => 'error', :message => "You did not enter an email address" ]
      else
        @user_subscription = Spree::UserSubscription.find_by_email(params[:email])
        if @user_subscription
          if @user_subscription.is_subscribed 
            response_msg = [ :status => 'error', :message => "Email address has already been subscribed" ]
          else
            @user_subscription.is_subscribed = true
            if @user_subscription.save
              response_msg = [ :status => 'success', :message => "Email address has been resubscribed" ]
            else
              response_msg = [ :status => 'error', :message => "Email address can not be saved. Please try again later" ]
            end
          end
        else 
          @new_user_subscription = Spree::UserSubscription.new(:email => params[:email])
          if @new_user_subscription.save
            response_msg = [ :status => 'success', :message => "Email address has been registered. Confirmation code will be sent." ]
          else
            response_msg = [ :status => 'error', :message => "Email address can not be saved. Please try again later" ]
          end
        end
      end
      respond_to do |format|
        format.js { render :json => response_msg }
      end    
    end

  end
end