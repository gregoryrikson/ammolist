require 'sidekiq'

class QaMailerWorker
  include Sidekiq::Worker

  def perform(question_id)
    question = Spree::Question.find(question_id)
    if question.user.present?
      QaAnswerMailer.answer_email(question).deliver
    end
  end
end
