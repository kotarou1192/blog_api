require 'test_helper'

class UserCreationControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
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
