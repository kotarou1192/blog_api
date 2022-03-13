require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @email = 'hoge@email.com'
    @user = User.new(name: 'hoge',
                     email: @email,
                     password: 'hogefuga')
    @user.save
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'password should be present (nonblank)' do
    assert_not @user.update_password(' ' * 6)
  end

  test 'password should have a minimum length' do
    assert_not @user.update_password('a' * 5)
  end

  test 'id should be present' do
    assert @user.id
  end

  test 'password_digest should be match digest' do
    assert @user.password_digest == User.digest(@user.password)
  end

  test 'exp should be updated' do
    assert @user.update(explanation: 'hogefuga')
  end

  test 'exp can be blank or nil' do
    @user.update(explanation: 'aaa')
    assert @user.update(explanation: nil)
    assert @user.update(explanation: '')
  end

  test 'exp should be less than 255' do
    assert_not @user.update(explanation: 'a' * 256)
  end

  test 'icon can be updated' do
    file = File.open('img.png', 'r')
    assert @user.icon.attach(io: file, filename: 'img.png')
  end

  test 'too large icon can\'t be updated' do
    file = File.open('large_img.jpg', 'r')
    assert_not @user.icon.attach(io: file, filename: 'large_img.jpg')
  end
end
