require 'HTTParty'
require 'Nokogiri'
class Scraper

    attr_accessor :root_page
    inec_base = "http://www.inecnigeria.org/?page_id=20"
    lgass_url = "http://www.inecnigeria.org/wp-content/themes/inec/lgass.php"
    ra_url = "http://www.inecnigeria.org/wp-content/themes/inec/ra.php"

	def initialise
	   @doc = HTTParty.get(inec_base)
	   @root_page = Nokogiri::HTML(doc)
	end

	def parse_states
	   root_page.css("select#sel_states").css("option").map{|k|[k.values.first,k.text]}
	end

	def get_lgas(state_id)
		resp = post_to_url(lgass_url, :body => { :id => state_id}).parsed_response
		Nokogiri::HTML(resp)
	end

	def get_ward(lga_id)
		resp = post_to_url(ra_url, :body => { :id => lga_id}).parsed_response
		Nokogiri::HTML(resp)
	end

	def get_polling_unit(state_id, lga_id, ward_id)
		resp = post_to_url(inec_base, body = {:sel_states => state_id, :sel_lgas => lga_id, :sel_ra => ward_id, :MM_insert => 'form1'})
	end

	def post_to_url(url=lgass_url, body)
		HTTParty.post(url, body)
	end

end