# require 'curb'
require 'json'
require_relative 'pollard'

CMD         = "curl -k -d 'grant_type=password&username=#{SECRETS["SERVICE_NET_ID"]}&password=#{SECRETS["SERVICE_PW"]}&scope=openid' -H 'Authorization: Basic #{SECRETS["BASE64_STRING"]}' -H 'Content-Type: application/x-www-form-urlencoded' 'https://auth.nyu.edu/oauth2/token'"
JSON_RESP   = JSON.parse(`#{CMD}`)

File.write(TOKEN_FILE, JSON.pretty_generate(JSON_RESP))
puts "New token generated to #{TOKEN_FILE } expires in #{JSON_RESP["expires_in"] / 60} minutes"
