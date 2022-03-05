require 'test_helper'

class SearchPostsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test 'should be found' do
    name = 'test_user'
    get '/search/posts?keywords=one'
    res = JSON.parse @response.body
    assert res.any? { |post| post['user_name'] == name }
  end

  test 'length should be 55' do
    user = User.find_by(name: 'test_user')
    100.times.each do |i|
      user.posts.new(title: "test-#{i}", body: "body-#{i}").save
    end
    keyword = 'test'
    get "/search/posts?keywords=#{keyword}&max_contents=55"
    res = JSON.parse @response.body
    assert res.size == 55
  end

  test 'length should be 100 + 2 - 55 in page 2' do
    user = User.find_by(name: 'test_user')
    100.times.each do |i|
      user.posts.new(title: "test-#{i}", body: "body-#{i}").save
    end
    keyword = '_'
    get "/search/posts?keywords=#{keyword}&max_contents=55&page=2"
    res = JSON.parse @response.body
    assert res.size == 100 + 2 - 55
  end

  test 'length should be 0' do
    user = User.find_by(name: 'test_user')
    100.times.each do |i|
      user.posts.new(title: "test-#{i}", body: "body-#{i}").save
    end
    keyword = '_'
    get "/search/posts?keywords=#{keyword}&max_contents=55&page=3"
    res = JSON.parse @response.body
    assert res.size.zero?
  end

  # order types
  # new / old / matched

  test 'first result id should be 1' do
    user = User.find_by(name: 'test_user')
    100.times.each do |i|
      user.posts.new(title: "test-#{i}", body: "body-#{i}").save
    end
    keyword = 'one _'
    get "/search/posts?keywords=#{keyword}&max_contents=55&page=1"
    res = JSON.parse @response.body
    assert res[0]['id'] == 1
  end

  test 'first result id should be latest' do
    user = User.find_by(name: 'test_user')
    100.times.each.with_index do |i, index|
      user.posts.new(title: "test-#{i}", body: "body-#{i}", id: index + 3).save
      @last_index = index + 3
    end
    keyword = 'one _'
    get "/search/posts?keywords=#{keyword}&max_contents=55&page=1&order_type=new"
    res = JSON.parse @response.body
    assert res[0]['id'] == @last_index
  end

  test 'first result id should be oldest' do
    user = User.find_by(name: 'test_user')
    100.times.each.with_index do |i, index|
      user.posts.new(title: "test-#{i}", body: "body-#{i}", id: index + 3).save
    end
    keyword = 'one _'
    get "/search/posts?keywords=#{keyword}&max_contents=55&page=1&order_type=old"
    res = JSON.parse @response.body
    assert res[0]['id'] == 1
  end
end
