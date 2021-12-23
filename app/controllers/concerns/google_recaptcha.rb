require 'json'
require 'net/http'

module GoogleRecaptcha
  extend ActiveSupport::Concern

  RECAPTCHA_SITE_VERIFY_URL = 'https://www.google.com/recaptcha/api/siteverify'.freeze

  if Rails.env == 'test'
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

  def verified_google_recaptcha?(minimum_score:, recaptcha_token:)
    return false unless minimum_score.is_a? Float

    response = request_to(recaptcha_token)

    @score = response['score'] || FOR_TEST_SCORE
    response['success'] && @score > minimum_score
  end

  def request_to(token)
    uri = URI.parse("#{RECAPTCHA_SITE_VERIFY_URL}?secret=#{RECAPTCHA_SECRET_KEY}&response=#{token}")
    recaptcha_raw_response = Net::HTTP.get_response(uri)
    JSON.parse(recaptcha_raw_response.body)
  end
end
