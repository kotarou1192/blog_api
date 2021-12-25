require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test_user')
  end

  test 'blank title should be NoTitle' do
    post = @user.posts.create(title: '', body: 'body')
    assert post.title == 'NoTitle'
  end

  test 'should be valid' do
    post = @user.posts.create(title: 'title', body: 'body')
    assert post
  end

  test 'too long title should be invalid' do
    post = @user.posts.new(title: 'a' * 256, body: 'body')
    assert_not post.save
  end

  test 'should be invalid' do
    post = @user.posts.new(title: 'title', body: '')
    assert_not post.save
  end

  test 'too long body should be invalid' do
    post = @user.posts.new(title: 'title', body: 'a' * 6001)
    assert_not post.save
  end
end
