require 'test_helper'

class UserCreationControllerTest < ActionDispatch::IntegrationTest
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

  test 'should be invalid' do
    valid_email = 'john1192@gmails.com'
    User.create(email: valid_email, name: 'john1192', password: 'a' * 6)
    post '/account/want_to_create', params: {value: {email: valid_email}}
    assert @response.status == 400
  end
end
