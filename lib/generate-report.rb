require 'date'
require 'fileutils'
require 'json'
require_relative 'pollard'

INPUT_FILE                = Dir.glob("./data/in/root*.csv").first
OUTPUT_DIR                = "./data/out/#{DateTime.now.strftime("%m-%d-%Y")}"
NOT_CHECKED_RESULTS_FILE  = "#{OUTPUT_DIR}/not-checked.json"
FOUND_RESULTS_FILE        = "#{OUTPUT_DIR}/found.json"
NOT_FOUND_RESULTS_FILE    = "#{OUTPUT_DIR}/not-found.json"

FileUtils.rm_rf   OUTPUT_DIR
FileUtils.mkdir_p OUTPUT_DIR

keys_to_keep    = ["Domain", "Email", "Is Suspended"]
data            = CSV.foreach(INPUT_FILE, headers: true).map(&:to_h)

users_to_check  = []
users_to_skip   = []
not_found_users = []
found_users     = []

data.each do |hash| 
  hash.delete_if  { |key, value| !keys_to_keep.include?(key) }
  hash = hash.map { |k, v| [k.strip, v] }.to_h

  next if hash["Is Suspended"] == "1"

  if hash["Email"].to_s.end_with?('@nyu.edu')
    hash['netid'] = hash["Email"].to_s.sub('@nyu.edu', '')
    users_to_check << hash
  else
    users_to_skip << hash
  end
end

def read_token 
  JSON.parse File.read(TOKEN_FILE)
end

def lookup(netID)
  cmd   = "curl --silent -L 'https://api.nyu.edu/identity-v2-sys/identity/unique-id/#{netID}?api_access_id=#{SECRETS["API_ACCESS_ID"]}' -H 'Authorization: Bearer #{read_token["access_token"]}'"
  resp  = `#{cmd}`
  JSON.parse(resp)
end


puts "NOT CHECKED: #{users_to_skip.length}"
File.write(NOT_CHECKED_RESULTS_FILE, JSON.pretty_generate(users_to_skip))

users_to_check.take(10).each_with_index do |hash, idx|
  netID = hash['netid']
  puts "checking #{netID} (#{idx}/#{users_to_check.length})"
  result = lookup(netID)
  if result.is_a?(Hash)
    not_found_users << hash.merge(result)
  elsif result.is_a?(Array) and result.first.is_a?(Hash)
    puts "-" + result.map { |r| r["affiliation_sub_type"] }.to_s
    found_users << hash.merge(result.first)
  else 
    puts "Couldn't handle #{netID}!"
  end
end

puts "FOUND: #{found_users.length}"
File.write(FOUND_RESULTS_FILE, JSON.pretty_generate(found_users), mode: 'a+')

puts "NOT FOUND: #{not_found_users.length}"
File.write(NOT_FOUND_RESULTS_FILE, JSON.pretty_generate(not_found_users), mode: 'a+')