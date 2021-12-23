# frozen_string_literal: true

require 'concerns/JWT'

class AuthController < ApplicationController

  # impl
  # https://qiita.com/shu1124/items/e8c37b73e015afc63074
  # what is jwt
  # https://qiita.com/Naoto9282/items/8427918564400968bd2b
  JWT_SECRET_KEY = Rails.env == 'test' ? 'secret' : Rails.application.credentials[:jwt_key]
  LOGIN_DATE_OF_EXPIRY = 10
  def create
    user = User.find_by(email: login_params[:email])
    if user&.authenticated?(login_params[:password])
      jwt = JWT::Provider.new(private_key: JWT_SECRET_KEY)
      token = jwt.generate(name: user.id, user_name: user.name, sub: request.domain, lim_days: LOGIN_DATE_OF_EXPIRY)
      render json: { token: token }
    else
      login_error
    end
  end

  private

  def login_error
    render json: { error: { messages: ['mistake email or password'] } }, status: :unauthorized
  end

  def login_params
    params.require(:value).permit(:email, :password)
  end
end
