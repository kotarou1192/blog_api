require 'test_helper'

class LoginSessionCleanupJobTest < ActiveJob::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test_user')
  end
end
