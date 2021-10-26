class UserCreationController < ApplicationController

  require "json"
  require "net/http"

  RECAPTCHA_SITE_VERIFY_URL = 'https://www.google.com/recaptcha/api/siteverify'

  if Rails.env == "test"
    # test_secret_key from here
    # https://developers.google.com/recaptcha/docs/faq
    test_site_key = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'
    test_secret_key = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'

    # not used
    # JS側で使う
    RECAPTCHA_SITE_KEY   = test_site_key

    # used
    RECAPTCHA_SECRET_KEY = test_secret_key
    # score ボット 0 --- 1 人間
    #
    FOR_TEST_SCORE = 0.6
  else
    # not used
    # JS側で使う
    RECAPTCHA_SITE_KEY   = Rails.application.credentials.recaptcha[:site_key]

    # used
    RECAPTCHA_SECRET_KEY = Rails.application.credentials.recaptcha[:secret_key]
    # score ボット 0 --- 1 人間
    #
    FOR_TEST_SCORE = Rails.application.credentials.recaptcha[:test_score]
  end


  # ユーザー作成用メール送信
  # TODO: セッションの期限を決める

  @score = 0

  def create
    creation_session = UserCreationSession.new(email: user_creation_params[:email])
    if !User.find_by(email: user_creation_params[:email]).nil? || !verified_google_recaptcha?(minimum_score: 0.5)
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

  def verified_google_recaptcha?(minimum_score:)
    return false unless minimum_score.is_a? Float

    response = request_to(user_creation_params['recaptchaToken'])

    @score = response['score'] || FOR_TEST_SCORE
    response['success'] && @score > minimum_score
  end

  def request_to(token)
    uri = URI.parse("#{RECAPTCHA_SITE_VERIFY_URL}?secret=#{RECAPTCHA_SECRET_KEY}&response=#{token}")
    recaptcha_raw_response = Net::HTTP.get_response(uri)
    JSON.parse(recaptcha_raw_response.body)
  end

  def user_creation_params
    return {} if params[:value].nil?

    params.require(:value).permit(:email, :recaptchaToken)
  end
end
