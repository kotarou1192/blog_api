require 'test_helper'

class JWTModuleTest < ActionDispatch::IntegrationTest
  def setup
    @jwt = JWT::Provider.new(private_key: 'secret'.freeze)
  end

  test 'should be valid' do
    name = 'my name is takashi'
    sub = 'this is my server'
    token = @jwt.generate(name: name, sub: sub, lim_days: 10)
    assert token && token.split('.').size == 3
  end

  test 'token should be valid' do
    name = 'my name = is takashiii'
    sub = 'my test server'
    token = @jwt.generate(name: name, sub: sub, lim_days: 10)
    assert @jwt.valid? token
  end

  test 'invalid signature should be rejected' do
    token = @jwt.generate(name: ';eval("exit()");bbb', sub: ';eval("exit()");test', lim_days: 10)
    token << 'has_no_comma_text;eval("exit()");'
    assert_not @jwt.valid? token
  end

  test 'invalid token body should be rejected' do
    token = @jwt.generate(name: 'name', sub: 'sub', lim_days: 10)
    danger_eval_base64 = Base64.urlsafe_encode64(';eval("exit()");')
    token = danger_eval_base64 + ';eval("exit()");1234' + token
    assert_not @jwt.valid? token
  end

  test 'invalid token type throws error' do
    token = @jwt.generate(name: 'bob', sub: 'sub', lim_days: 10)
    token << '.too;eval("exit()");' << '.many' << '.commas'
    assert_not @jwt.valid? token
  end

  test 'reject not jwt' do
    assert_not @jwt.valid?('12345')
  end

  test 'old jwt should be rejected' do
    token = @jwt.generate(name: 'bob', sub: 'sub', lim_days: 10)
    travel_to 100.days.since
    assert_not @jwt.valid? token
  end
end
