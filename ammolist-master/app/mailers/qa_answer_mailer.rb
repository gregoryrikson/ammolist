class QaAnswerMailer < ActionMailer::Base
  def answer_email(question)
    
    @question = question
    @user = question.user
    
    #puts @user.email.to_yaml
    #abort('sss')
    
    mail(to: @user.email, subject: t('answer_email.subject'))
    
  end
end
