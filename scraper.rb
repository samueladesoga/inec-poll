require 'HTTParty'
require 'Nokogiri'
require 'pry'
require 'json'
class Scraper

    attr_accessor :root_page
    INEC_BASE_URL = "http://www.inecnigeria.org/?page_id=20"
    LAGASS_URL = "http://www.inecnigeria.org/wp-content/themes/inec/lgass.php"
    RA_URL = "http://www.inecnigeria.org/wp-content/themes/inec/ra.php"

	def initialize
	   @doc = HTTParty.get(INEC_BASE_URL)
	   @root_page = Nokogiri::HTML(@doc)
	end

	def parse_states
	   @root_page.css("select#sel_states").css("option").map{|k|[k.values.first,k.text]}
	end

	def get_lgas(state_id)
		resp = post_to_url(LAGASS_URL, :body => { :id => state_id}).parsed_response
		Nokogiri::HTML(resp).css("option").map{|k|[k.values.first,k.text]}
	end

	def get_ward(lga_id)
		resp = post_to_url(RA_URL, :body => { :id => lga_id}).parsed_response
		Nokogiri::HTML(resp).css("option").map{|k|[k.values.first,k.text]}
	end

	def get_polling_unit(state_id, lga_id, ward_id)
		resp = post_to_url(INEC_BASE_URL, :body => {:sel_states => state_id, :sel_lgas => lga_id, :sel_ra => ward_id, :MM_insert => 'form1'})
		Nokogiri::HTML(resp.parsed_response).css("td a").map{|pu|pu.text}
	end

	def post_to_url(url=LAGASS_URL, body)
		HTTParty.post(url, body)
	end

	def main
		polling_units = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
		parse_states.each { |value, state_name|
			if value.to_i > 0
				get_lgas(value.to_i).each { |lg_v, lg_name|
					if lg_v.to_i > 0
						get_ward(lg_v.to_i).each { |w_v, w_name|
							if w_v.to_i > 0
								pus = get_polling_unit(value.to_i, lg_v.to_i, w_v.to_i)
								polling_units[state_name][lg_name][w_name] = pus.uniq
								puts "******#{state_name}, #{lg_name}, #{w_name}***********"
								#pus.each { |pu|
									#puts "******#{state_name}, #{lg_name}, #{w_name}, #{pu}*******"
								#	polling_units[state_name][lg_name][w_name][pu]
								#	puts polling_units
								#}								
							end
						}
					end
				}
			end
		}
		File.open("output.json", "w+") { |file| file.write(JSON.pretty_generate(polling_units)) }
	end
end