require 'date'
require 'json'
require_relative 'pollard'

FOUND_FILE    = Dir.glob("./data/out/*/found.json").first
TO_PRUNE_FILE = "#{OUTPUT_DIR}/to-prune.json"

student_sub_types         = ["degree", "noncredit tandon", "noncredit interdisc", "noncredit steinhardt", "nondegree sps"]
alum_sub_types            = ["alumni", "nongrad_alumni", "account_sponsored_alum"]
fac_and_staff_subtypes    = ["administrator", "research assistant", "researcher", "visiting_scholar", "adjunct faculty", "faculty", "som_faculty", "nyumc_affiliate", "som_employee", "technical staff", "research_affiliate", "contractor", "office staff", "post doctoral fellow", "visiting_academic_other"]
former_fac_staff_subtypes = ["retired faculty", "retired employee"]
active_sub_types          = student_sub_types + fac_and_staff_subtypes
former_sub_types          = alum_sub_types + former_fac_staff_subtypes
relevant_sub_types        = student_sub_types + alum_sub_types + fac_and_staff_subtypes + former_fac_staff_subtypes

to_prune = [] 

data = JSON.parse File.read(FOUND_FILE)
data.each do |hash|
  active = hash['identity'].map do |id| 
    id if active_sub_types.include?(id['affiliation_sub_type'])
  end.compact

  if active.empty? 
    to_prune << hash
  else 
    latest = active.map { |a| Date.parse(a['strict_end_date']) }.sort.last
    if DateTime.now > latest 
      to_prune << hash
    end
  end
end

puts "\n#{to_prune.length} accounts flagged for suspension"
File.write(TO_PRUNE_FILE, JSON.pretty_generate(to_prune))


