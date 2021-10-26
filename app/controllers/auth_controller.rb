# frozen_string_literal: true

require 'jwt'

class AuthController < ApplicationController

  # impl
  # https://qiita.com/shu1124/items/e8c37b73e015afc63074
  # jwt lib
  # https://github.com/jwt/ruby-jwt
  # what is jwt
  # https://qiita.com/Naoto9282/items/8427918564400968bd2b
  def create
    jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), 'optional-kid')
    user = User.find_by(email: login_params[:email])

    if user&.authenticated?(login_params[:password])
      payload = { data: 'success to logged in' }
      headers = { kid: jwk.kid }
      token = JWT.encode(payload, jwk.keypair, 'RS512', headers)
      render json: { token: token }
    else
      login_error
    end
  end

  private

  def jwt_base
    jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), 'optional-kid')
    user = User.find_by(email: login_params[:email])

    if user&.authenticated?(login_params[:password])
      payload = { data: 'success to logged in' }
      headers = { kid: jwk.kid }
      token = JWT.encode(payload, jwk.keypair, 'RS512', headers)
      jwk_loader = lambda do |options|
        @cached_keys = nil if options[:invalidate] # need to reload the keys
        @cached_keys ||= { keys: [jwk.export] }
      end
      begin
        response = JWT.decode(token, nil, true, { algorithms: ['RS512'], jwks: jwk_loader })
        return render json: response
      rescue JWT::JWKError
        login_error
      rescue JWT::DecodeError
        render status: 500, json: { error: { message: ['unknown error'] } }
      end
    end
  end

  def login_error
    render json: { error: { messages: ['mistake emal or password'] } }, status: :unauthorized
  end

  def login_params
    params.require(:value).permit(:email, :password)
  end
end
