require 'concerns/JWT'

module Authenticate
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # impl
  # https://qiita.com/shu1124/items/e8c37b73e015afc63074
  # what is jwt
  # https://qiita.com/Naoto9282/items/8427918564400968bd2b
  JWT_SECRET_KEY = Rails.env == 'test' ? 'secret' : Rails.application.credentials[:jwt_key]

  def authenticate_failed
    render json: { error: { messages: ['invalid token. retry to login'] } }, status: :unauthorized
  end

  def authenticated?
    @jwt = JWT::Provider.new(private_key: JWT_SECRET_KEY)
    authenticate_with_http_token do |token, _options|
      return false unless @jwt.valid? token

      uuid = user_id_from_jwt(token)
      @user = User.find_by(id: uuid)
      return true if @user
    end
    false
  end

  def user_id_from_jwt(token)
    parsed = @jwt.decode token
    parsed[1]['name']
  end
end
