#!/bin/ruby
require 'uri'
require 'net/http'
# http://rubyforge.org/snippet/detail.php?type=snippet&id=148
require 'simplejsonparser'
# require 'nkf'

url = "https://github.com/api/v2/json/repos/show/gosyujin"

# GET
uri = URI.parse(url)
proxy_class = Net::HTTP::Proxy(ENV["PROXY"], 8080)
http = proxy_class.new(uri.host)
http.start do |http|
	res = http.get(uri.path)
	if res.code == "200" then
		json = res.body
		jsonparse = JsonParser.new.parse(json)
		for i in 0..jsonparse['repositories'].length - 1
			puts `git clone git@github.com:#{jsonparse['repositories'][i]['owner']}/#{jsonparse['repositories'][i]['name']}.git`
		end
	else
		print "#{res.code}\n"
	end
end
