require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @email = 'exapmle@example.com'
    @user = User.create(name: 'hoge',
                            email: @email,
                            password: 'hogefuga')
    @session = Session.new
    @session.user = @user
    @session.save
  end

  test 'token should be present' do
    assert @session.session_id
  end

  test 'should be valid' do
    @session.created_at = 20.days.ago

    assert @session.still_valid?
  end

  test 'should be invalid' do
    @session.created_at = 40.days.ago

    assert_not @session.still_valid?
  end
end
