#!/bin/ruby
require 'uri'
require 'net/http'
# http://rubyforge.org/snippet/detail.php?type=snippet&id=148
require 'simplejsonparser'
# require 'nkf'

def get(url)
	uri = URI.parse(url)
	proxy_class = Net::HTTP::Proxy(ENV["PROXY"], 8080)
	http = proxy_class.new(uri.host)
	http.start do |http|
		res = http.get(uri.path)
		if res.code == "200" then
			json = res.body
			JsonParser.new.parse(json)
		else
			print "#{res.code}\n"
		end
	end
end

if ARGV.length == 0 then
	print "Usage: gh.rb USERNAME [github|gist]\n"
	exit 1
end

user = ARGV[0]
url = ""
case ARGV[1]
when "github" then 
	url = "https://github.com/api/v2/json/repos/show/#{user}"
	param = get(url)
	for i in 0..param['repositories'].length - 1
		owner = param['repositories'][i]['owner']
		name = param['repositories'][i]['name']
		puts `git clone git@github.com:#{owner}/#{name}.git`
	end
when "gist" then
	url = "http://gist.github.com/api/v1/json/gists/#{user}"
	param = get(url)
	for i in 0..param['gists'].length - 1
		files = param['gists'][i]['files'][0].split(".")[0]
		repo = param['gists'][i]['repo']
		puts `git clone git://gist.github.com/#{repo}.git #{files}`
	end
end
