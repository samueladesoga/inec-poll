require 'HTTParty'
require 'Nokogiri'
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
	   puts @root_page
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
		resp = post_to_url(INEC_BASE_URL, body = {:sel_states => state_id, :sel_lgas => lga_id, :sel_ra => ward_id, :MM_insert => 'form1'})
	end

	def post_to_url(url=LAGASS_URL, body)
		HTTParty.post(url, body)
	end

	def main
		parse_states.each { |value, state_name|
			get_lgas(value.to_i).each { |lg_v, lg_name|
				puts get_ward(lg_v.to_i)
			}
		}
	end
end