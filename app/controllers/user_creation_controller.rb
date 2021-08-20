class UserCreationController < ApplicationController
  # ユーザー作成用メール送信
  # TODO: セッションの期限を決める
  def create
    creation_session = UserCreationSession.new(user_creation_params)
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
