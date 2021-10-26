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
    done = true
    (LoginSession::MAX_SESSION_NUMBERS + 1).times do
      done = false if @user.login_sessions.create
    end
    assert_not done
  end
end
