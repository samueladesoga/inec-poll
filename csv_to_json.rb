require 'csv'
require 'json'

extracted_data = CSV.table('SenatorialDistrict_Massaged.csv', :headers => false , :encoding => 'ISO-8859-1')

senatorial_districts = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
extracted_data.each {|line|
	senatorial_districts[line[0].strip][line[1].strip]= line[2].split(',').map(&:strip)
}

File.open('senatorial_districts.json', 'w') do |file|
  file.puts JSON.pretty_generate(senatorial_districts)
end


