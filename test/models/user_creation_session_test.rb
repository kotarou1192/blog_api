require 'test_helper'

class UserCreationSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @email = 'hoge@email.com'
    @session = UserCreationSession.new(email: @email)
    @session.save
  end

  test 'should be valid' do
    assert @session.valid?
  end

  test 'session_id should be present' do
    assert @session.session_id
  end

  test 'this email address should be valid' do
    @session.email = 'awsisgod'
    assert_not @session.valid?
  end
end
