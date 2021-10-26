require 'test_helper'

class LoginSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test_user')
  end

  test 'should be valid' do
    session = @user.login_sessions.create
    assert session
  end

  test "session numbers should be less than #{LoginSession::MAX_SESSION_NUMBERS}" do
    tokens = LoginSession::MAX_SESSION_NUMBERS.times.map do
      session = @user.login_sessions.create
      session.session_id
    end
    new_token = @user.login_sessions.create.session_id

    assert new_token && tokens.none?(new_token)
  end
end
