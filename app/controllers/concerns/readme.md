## Library
### JWT

RFC 7519 in japanese ->  https://tex2e.github.io/rfc-translater/html/rfc7519.html  

usage  
```ruby
require 'concern/JWT' # you have to require correct path

jwt_provider = JWT::Provider.new(private_key: 'your private key')
token = jwt_provider.generate(sub: 'your server name', name: 'account id or other')
parsed_jwt_data = jwt_provider.decode(token)
if jwt_provider.tampered?(token)
  puts 'this token has been tampered'
  return
end
puts 'token is ok!'
```  
###methods

#### initialize(private_key:, algorithm:)
return self  
  
**arguments**  
- private_key:
  - your key string.
- algorithm:
  - default is hs256. other algorithms are not supported. "alg": "none" is not supported too.

#### generate(sub:, name:)
return string  
  
**arguments**  
- sub:
  - sub means subject that is your application's identifier.
- name:
  - name is protected with digital signature.
  
#### decode(token)
return `Array<Hash | String>`  
  
**arguments**  
- token
  - jwt

#### tampered?(token)
return true/false  
if given token has been tampered, returns `true`.  
  
**arguments**  
- token
  - jwt 

