# frozen_string_literal: true

# JWT Authorization
#
# Supported algorithms:
# HS256
#
module JWT
  # ==initialize()
  # initialize JWT class
  # ==tempered?()
  # check given token correct
  # ==generate()
  # generate jwt
  # ==decode()
  # parse jwt
  class Provider
    extend ActiveSupport::Concern
    require 'OpenSSL'
    require 'base64'
    require 'JSON'
    # reject 'alg: none'
    ALLOWED_ALG_TYPES = %w[hs256].freeze
    JWT_ALG_TO_HASH_ALG = {
      'hs256' => 'sha256'
    }.freeze
    CONTENT_TYPE = 'JWT'

    def initialize(private_key:, algorithm: 'hs256')
      raise TypeError, "algorithm type: #{algorithm} is incorrect" if ALLOWED_ALG_TYPES.none? algorithm.downcase

      @alg = algorithm.downcase
      @key = private_key
    end

    def tempered?(jwt)
      parsed = decode jwt
      signature = parsed.pop

      unsigned_token = parsed.map { |obj| Base64.urlsafe_encode64 JSON.generate obj }.join('.').delete('=')

      signature == sign(unsigned_token)
    end

    def generate(payload_hash)
      header = {
        alg: @alg,
        typ: CONTENT_TYPE
      }
      payload = payload_hash
      unsigned_token = Base64.urlsafe_encode64(JSON.generate(header)).delete('=') << '.' << Base64.urlsafe_encode64(JSON.generate(payload)).delete('=')
      signature = sign unsigned_token
      unsigned_token << '.' << signature
    end

    def decode(jwt)
      parsed_jwt = jwt.split('.')
      raise TypeError, 'it may not be jwt' unless parsed_jwt.size == 3

      parsed_jwt.map.with_index do |obj, index|
        next obj if index == 2

        JSON.parse Base64.urlsafe_decode64(obj)
      end
    end

    private

    def sign(data)
      OpenSSL::HMAC.hexdigest(JWT_ALG_TO_HASH_ALG[@alg], @key, data)
    end
  end
end
