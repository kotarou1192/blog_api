class UserCreationController < ApplicationController
  include Recaptcha::Adapters::ControllerMethods

  # not used
  # JS側で使う
  RECAPTCHA_SITE_KEY   = Rails.application.credentials.recaptcha[:site_key]

  # used
  RECAPTCHA_SECRET_KEY = Rails.application.credentials.recaptcha[:secret_key]
  # score ボット 0 --- 1 人間

  # ユーザー作成用メール送信
  # TODO: セッションの期限を決める
  def create

    creation_session = UserCreationSession.new(user_creation_params)
    unless verify_recaptcha(model: creation_session, minimum_score: 0.5, secret_key: RECAPTCHA_SECRET_KEY)
      puts "failed"
      return render status: 400, json: {message: creation_session.errors.messages}
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

  def user_creation_params
    return {} if params[:value].nil?

    params.require(:value).permit(:email)
  end
end
