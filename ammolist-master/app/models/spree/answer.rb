class Spree::Answer < ActiveRecord::Base
  belongs_to :question

  validates :content, presence: true

  #after_create :send_email, if: ->() { SpreeProductsQa.send_email? }
  
  after_create :send_email

  def send_email
        #QaMailerWorker.perform_async(self.question.id) if self.question.present?
        QaAnswerMailer.answer_email(self.question).deliver if self.question.present?
  end
end
