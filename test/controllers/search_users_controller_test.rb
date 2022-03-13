require 'test_helper'

class SearchUsersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test 'should be found' do
    name = 'test-user'
    get "/search/users?keywords=#{name}"
    res = JSON.parse @response.body
    assert res.any? { |user| user['name'] == name }
  end

  test 'length should be 55' do
    100.times.each do |i|
      User.new(name: "test#{i}", email: "example#{i}@example.com", password: 'password').save
    end
    name = 'test'
    get "/search/users?keywords=#{name}&max_contents=55"
    res = JSON.parse @response.body
    assert res.size == 55
  end

  test 'length should be 100 + 2 - 55 in page 2' do
    100.times.each do |i|
      User.new(name: "test#{i}", email: "example#{i}@example.com", password: 'password').save
    end
    name = 'test'
    get "/search/users?keywords=#{name}&max_contents=55&page=2"
    res = JSON.parse @response.body
    assert res.size == 100 + 2 - 55
  end
end
