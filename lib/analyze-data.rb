require 'date'
require 'json'
require_relative 'pollard'

FOUND_FILE      = Dir.glob("./data/out/*/found.json").first
NOT_FOUND_FILE  = Dir.glob("./data/out/*/not-found.json").first
TO_PRUNE_JSON   = "#{OUTPUT_DIR}/to-prune.json"
TO_PRUNE_CSV    = "#{OUTPUT_DIR}/to-prune.csv"
NOT_FOUND_CSV   = "#{OUTPUT_DIR}/not-found.csv"

student_sub_types         = ["degree", "noncredit tandon", "noncredit interdisc", "noncredit steinhardt", "nondegree sps"]
alum_sub_types            = ["alumni", "nongrad_alumni", "account_sponsored_alum"]
fac_and_staff_subtypes    = ["administrator", "research assistant", "researcher", "visiting_scholar", "adjunct faculty", "faculty", "som_faculty", "nyumc_affiliate", "som_employee", "technical staff", "research_affiliate", "contractor", "office staff", "post doctoral fellow", "visiting_academic_other", "retired faculty", "retired employee"] # extra grace for retirees to (re)consider later
active_sub_types          = student_sub_types + fac_and_staff_subtypes 
relevant_sub_types        = student_sub_types + alum_sub_types + fac_and_staff_subtypes

to_prune = [] 

data = JSON.parse File.read(FOUND_FILE)
data.each do |hash|
  active = hash['identity'].map do |id| 
    id if active_sub_types.include?(id['affiliation_sub_type'])
  end.compact

  hash['primary affiliation'] = hash['identity'].first["primary_affiliation"]

  if active.empty? 
    to_prune << hash
  else 
    latest = active.map { |a| Date.parse(a['grace_end_date']) }.sort.last
    hash['latest date'] = latest.to_s
    to_prune << hash if (DateTime.now > latest)
  end
end

puts "#{to_prune.length} accounts flagged for suspension"
File.write(TO_PRUNE_JSON, JSON.pretty_generate(to_prune))

simplified = to_prune.map do |hash| 
  {
    "Domain":         hash["Domain"],
    "Contact Email":  hash["Contact Email"],
    "Email":          hash["Email"],
    "netid":          hash["netid"],
    "primary affil":  hash["primary affiliation"],
    "latest date":    hash["latest date"]
  }
end

CSV.open(TO_PRUNE_CSV, "wb") do |csv|
  csv << simplified.first.keys
  simplified.each do |hash|
    csv << hash.values
  end
end

not_found = JSON.parse File.read(NOT_FOUND_FILE)
puts "#{not_found.length} accounts not found by NYU ID API"

nf_simplified = not_found.map do |hash| 
  {
    "Domain":         hash["Domain"],
    "Contact Email":  hash["Contact Email"],
    "Email":          hash["Email"],
    "netid":          hash["netid"],
    "primary affil":  hash["primary affiliation"],
    "latest date":    hash["latest date"]
  }
end

CSV.open(NOT_FOUND_CSV, "wb") do |csv|
  csv << nf_simplified.first.keys
  nf_simplified.each do |hash|
    csv << hash.values
  end
end



