require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test_user')
  end

  test 'should be valid' do
    valid_email = @user.email
    valid_password = 'password'
    post '/auth', params: { value: { email: valid_email, password: valid_password } }
    assert @response.status == 200
  end

  test 'invalid password should be rejected' do
    valid_email = @user.email
    invalid_password = 'password' << 'invalid'
    post '/auth', params: { value: { email: valid_email, password: invalid_password } }
    assert @response.status == 401
  end

  test 'invalid email should be rejected' do
    invalid_email = @user.email + '.invalid'
    valid_password = 'password'
    post '/auth', params: { value: { email: invalid_email, password: valid_password } }
    assert @response.status == 401
  end

  test 'invalid email and password pair should be rejected' do
    invalid_email = @user.email + '.invalid'
    invalid_password = 'password' << 'invalid'

    post '/auth', params: { value: { email: invalid_email, password: invalid_password } }
    assert @response.status == 401
  end
end
