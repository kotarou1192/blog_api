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
end
