require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test_user')
  end

  test 'should be valid' do
    valid_email = @user.email
    valid_password = 'password'
    post '/users/login', params: { value: { email: valid_email, password: valid_password } }
    assert @response.status == 200
  end

  test 'token should be refreshed' do
    valid_email = @user.email
    valid_password = 'password'

    tokens = 10.times.map do
      post '/users/login', params: { value: { email: valid_email, password: valid_password } }
      res = JSON.parse @response.body
      res['token']
    end
    post '/users/login', params: { value: { email: valid_email, password: valid_password } }

    new_token = (JSON.parse @response.body)['token']
    assert new_token && tokens.none?(new_token)
  end

  test 'invalid password should be rejected' do
    valid_email = @user.email
    invalid_password = 'password' << 'invalid'
    post '/users/login', params: { value: { email: valid_email, password: invalid_password } }
    assert @response.status == 400
  end

  test 'invalid email should be rejected' do
    invalid_email = @user.email + '.invalid'
    valid_password = 'password'
    post '/users/login', params: { value: { email: invalid_email, password: valid_password } }
    assert @response.status == 400
  end

  test 'invalid email and password pair should be rejected' do
    invalid_email = @user.email + '.invalid'
    invalid_password = 'password' << 'invalid'

    post '/users/login', params: { value: { email: invalid_email, password: invalid_password } }
    assert @response.status == 400
  end
end
