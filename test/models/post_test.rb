require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test-user')
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

  test 'should be removed' do
    post = @user.posts.create(title: 'title', body: 'body')
    assert post.destroy
  end

  test 'should be updated' do
    params = {
      title: '',
      body: 'updated_body'
    }
    post = @user.posts.create(title: 'title', body: 'body')
    assert post.update(params)
    assert post.title == 'NoTitle'
  end

  test 'should not be updated' do
    params = {
      title: '',
      body: ''
    }
    post = @user.posts.create(title: 'title', body: 'body')
    assert_not post.update params
  end
end
