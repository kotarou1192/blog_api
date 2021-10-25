require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
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
