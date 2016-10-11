require 'bundler/setup'
require 'json'
require 'open-uri'
require 'uri'
require 'pry'
require 'scraperwiki'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def popong_api_data
  api_url = 'http://api.popong.com/v0.1/person/search?api_key=test&per_page=1000&page=%s'

  page = 1
  data = []

  loop do
    begin
      url = api_url % page
      puts "Scraping #{url}"
      response = JSON.parse(open(url).read, symbolize_names: true)
      data += response[:items].map do |item|
        item[:address_id] = JSON.generate(item[:address_id].to_a)
        item[:education_id] = JSON.generate(item[:education_id].to_a)
        item
      end
      page += 1
    rescue OpenURI::HTTPError => e
      break if e.io.status.first.to_i == 404
      raise
    end
  end

  data
end

ScraperWiki.save_sqlite([:id], popong_api_data)
