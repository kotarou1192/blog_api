require 'test_helper'

class JWTModuleTest < ActionDispatch::IntegrationTest
  def setup
    @jwt = JWT::Provider.new(private_key: 'secret'.freeze)
  end

  test 'should be valid' do
    name = 'my name is takashi'
    sub = 'this is my server'
    token = @jwt.generate(name: name, sub: sub)
    assert token && token.split('.').size == 3
  end

  test 'token should be valid' do
    name = 'my name = is takashiii'
    sub = 'my test server'
    token = @jwt.generate(name: name, sub: sub)
    assert_not @jwt.tampered? token
  end

  test 'invalid signature should be rejected' do
    token = @jwt.generate(name: ';eval("exit()");bbb', sub: ';eval("exit()");test')
    token << 'has_no_comma_text;eval("exit()");'
    assert @jwt.tampered? token
  end

  test 'invalid token body should be rejected' do
    token = @jwt.generate(name: 'name', sub: 'sub')
    danger_eval_base64 = Base64.urlsafe_encode64(';eval("exit()");')
    token = danger_eval_base64 + ';eval("exit()");1234' + token
    assert @jwt.tampered? token
  end

  test 'invalid token type throws error' do
    token = @jwt.generate(name: 'bob', sub: 'sub')
    token << '.too;eval("exit()");' << '.many' << '.commas'
    assert @jwt.tampered? token
  end

  test 'reject not jwt' do
    assert @jwt.tampered?('12345')
  end
end
