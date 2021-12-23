class UserCreationController < ApplicationController
  include GoogleRecaptcha
  @score = 0

  def create
    creation_session = UserCreationSession.new(email: user_creation_params[:email])
    if !User.find_by(email: user_creation_params[:email]).nil? || !verified_google_recaptcha?(minimum_score: 0.5, 
                                                                                              recaptcha_token: user_creation_params[:recaptchaToken])
      return render status: 400, json: { message: 'failed' }
    end

    if creation_session.save
      enqueue_creation_session(creation_session)
      creation_session.send_account_creation_email
      render json: { message: 'mail that includes account creation link has been sent' }
    else
      # TODO: エラーメッセージを正確に
      # TODO: レスポンスのjsonの形式の統一
      render status: 400, json: { message: 'failed' }
    end
  end

  private

  def enqueue_creation_session(session)
    UserCreationSessionsCleanupJob.set(wait_until: session.date_limit).perform_later(session.session_id)
  end

  def user_creation_params
    return {} if params[:value].nil?

    params.require(:value).permit(:email, :recaptchaToken)
  end
end
