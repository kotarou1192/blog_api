require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    # test_secret_key from here
    # https://developers.google.com/recaptcha/docs/faq
    test_site_key = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'
    test_secret_key = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'
    Rails.application.credentials.recaptcha[:secret_key] = test_secret_key
    Rails.application.credentials.recaptcha[:site_key] = test_site_key
    Rails.application.credentials.recaptcha[:test_score] = 0.6
  end

  test 'should be valid' do
    valid_email = 'pow@pow.com'
    valid_password = 'password1234'
    valid_name = 'john1192'
    post '/account/want_to_create', params: {value: {email: valid_email}}
    session = UserCreationSession.find_by(email: valid_email)
    assert session

    post '/users', params: {value: {session_id: session.session_id, password: valid_password, name: valid_name}}

    user = User.find_by(email: valid_email)
    assert user
  end
end
