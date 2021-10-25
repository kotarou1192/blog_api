require 'test_helper'

class UserCreationControllerTest < ActionDispatch::IntegrationTest
  def setup
    # test_secret_key from here
    # https://developers.google.com/recaptcha/docs/faq
    test_site_key = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'
    test_secret_key = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'
    Rails.application.credentials.recaptcha[:secret_key] = test_secret_key
    Rails.application.credentials.recaptcha[:site_key] = test_site_key
    Rails.application.credentials.recaptcha[:test_score] = 0.6
  end


  test 'invalid email should be rejected' do
    invalid_email = 'pow'
    post '/account/want_to_create', params: {value: {email: invalid_email}}
    session = UserCreationSession.find_by(email: invalid_email)
    assert_not session
  end

  test 'should be valid' do
    valid_email = 'john1192@gmails.com'
    post '/account/want_to_create', params: {value: {email: valid_email}}
    session = UserCreationSession.find_by(email: valid_email)
    assert session
  end
end
