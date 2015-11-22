module Spree
  module Admin
    class QuestionsController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def index
        @collection = @collection.page params[:page]
      end

      def pending
        @collection = Spree::Question.not_answered.joins(:product).map(&:product)
      end
    end
  end
end
