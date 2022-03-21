require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    valid_email = 'test@example.com'
    valid_password = 'password'
    post '/auth', params: { value: { email: valid_email, password: valid_password } }
    @token = (JSON.parse @response.body)['token']
    @user = User.find_by(name: 'test-user')
  end

  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end

  test 'should be valid' do
    valid_email = 'pow@pow.com'
    valid_password = 'password1234'
    valid_name = 'john1192'
    post '/account/want_to_create', params: { value: { email: valid_email } }
    session = UserCreationSession.find_by(email: valid_email)
    assert session

    post '/users', params: { value: { session_id: session.session_id, password: valid_password, name: valid_name } }

    user = User.find_by(email: valid_email)
    assert user
  end

  test 'should be mine' do
    get "/users/#{@user.name}", headers: { Authorization: "Bearer #{@token}" }
    res = JSON.parse @response.body
    assert res['is_my_page'] == true
  end

  test 'should not be mine' do
    get "/users/#{@user.name}"
    res = JSON.parse @response.body
    assert_not res['is_my_page']
  end

  test 'should not be mine with token' do
    get '/users/test-user-2', headers: { Authorization: "Bearer #{@token}" }
    res = JSON.parse @response.body
    assert_not res['is_my_page']
  end

  test 'user should be updated' do
    new_name = 'new-name'
    new_exp = 'this is my account.'
    file = File.read('./img.png')
    put "/users/#{@user.name}", params: { name: new_name, explanation: new_exp, icon: file },
                                headers: { Authorization: "Bearer #{@token}" }
    updated_user = User.find_by(name: @user.name)
    assert updated_user.explanation == new_exp
  end

  # TODO: fileのアップロードがサイズ以外の理由でfailedしてるので治す
  test 'too large image should be rejected' do
    new_name = 'new-name'
    new_exp = 'this is my account.'
    file = File.read('./large_img.jpg')
    put "/users/#{@user.name}", params: { name: new_name, explanation: new_exp, icon: file },
                                headers: { Authorization: "Bearer #{@token}" }
    assert @response.status == 400
  end
end
