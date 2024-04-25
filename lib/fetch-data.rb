require 'date'
require 'fileutils'
require 'json'
require 'ruby-progressbar'

require_relative 'pollard'

INPUT_FILE                = Dir.glob("./data/in/root*.csv").first
NETID_MAP_FILE            = "./data/in/netid_map.json"
NOT_CHECKED_RESULTS_FILE  = "#{OUTPUT_DIR}/not-checked.json"
FOUND_RESULTS_FILE        = "#{OUTPUT_DIR}/found.json"
NOT_FOUND_RESULTS_FILE    = "#{OUTPUT_DIR}/not-found.json"
TOKEN                     = JSON.parse File.read(TOKEN_FILE)
NETID_MAP                 = JSON.parse File.read(NETID_MAP_FILE)

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
    if NETID_MAP.key?(hash["Email"])
      hash["Contact Email"] = hash["Email"]
      puts "swapping #{hash["Email"]} for #{NETID_MAP[hash["Email"]]}!"
      hash["Email"] = NETID_MAP[hash["Email"]] 
    end
    hash['netid'] = hash["Email"].to_s.sub('@nyu.edu', '')
    users_to_check << hash
  else
    users_to_skip << hash
  end
end

def lookup(netID)
  cmd   = "curl --silent -L 'https://api.nyu.edu/identity-v2-sys/identity/unique-id/#{netID}?api_access_id=#{SECRETS["API_ACCESS_ID"]}' -H 'Authorization: Bearer #{TOKEN["access_token"]}'"
  resp  = `#{cmd}`
  JSON.parse(resp)
end


puts "NOT CHECKED: #{users_to_skip.length}"
File.write(NOT_CHECKED_RESULTS_FILE, JSON.pretty_generate(users_to_skip))

# progressbar = ProgressBar.create(:title => "Users", :total => users_to_check.length)

users_to_check.each_with_index do |hash, idx|
  netID = hash['netid']
  puts "checking #{netID} (#{idx}/#{users_to_check.length})"
  result = lookup(netID)
  if result.is_a?(Hash)
    hash["response"] = result
    not_found_users << hash
  elsif result.is_a?(Array)
    hash["identity"] = result
    found_users << hash
  else 
    puts "Couldn't handle #{netID}!"
  end
  # progressbar.increment
end

puts "FOUND: #{found_users.length}"
File.write(FOUND_RESULTS_FILE, JSON.pretty_generate(found_users))

puts "NOT FOUND: #{not_found_users.length}"
File.write(NOT_FOUND_RESULTS_FILE, JSON.pretty_generate(not_found_users))