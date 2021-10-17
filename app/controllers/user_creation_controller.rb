class UserCreationController < ApplicationController

  require "json"
  require "net/http"

  RECAPTCHA_SITE_VERIFY_URL = 'https://www.google.com/recaptcha/api/siteverify'

  # not used
  # JS側で使う
  RECAPTCHA_SITE_KEY   = Rails.application.credentials.recaptcha[:site_key]

  # used
  RECAPTCHA_SECRET_KEY = Rails.application.credentials.recaptcha[:secret_key]
  # score ボット 0 --- 1 人間

  # ユーザー作成用メール送信
  # TODO: セッションの期限を決める

  @score = 0

  def create

    creation_session = UserCreationSession.new(email: user_creation_params[:email])
    unless verified_google_recaptcha?(minimum_score: 0.5)
      puts "failed. score = #{@score}"
      return render status: 400, json: {message: "you may be a robot. score is #{@score}"}
    end

    if creation_session.save
      creation_session.send_account_creation_email
      render json: { message: 'mail that includes account creation link has been sent' }
    else
      # TODO: エラーメッセージを正確に
      # TODO: レスポンスのjsonの形式の統一
      render status: 400, json: { message: 'failed' }
    end
  end

  private

  def verified_google_recaptcha?(minimum_score:)
    return false unless minimum_score.is_a? Float

    response = request_to(RECAPTCHA_SECRET_KEY)

    p response
    @score = response['score'] if response['score']
    response['success'] && response['source'] > minimum_score
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
