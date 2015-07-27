#!/usr/bin/env ruby
require 'optparse'
require "uri"
require 'net/http'
require 'net/https'

def postToGhostbin(pdata,lang='text',pass='',title='')
	https = Net::HTTP.new('www.ghostbin.com',443)
	https.use_ssl = true
	unless pass
		pass = '';
	end
	unless title
		title = ''
	end
	postdata = pdata
	postdata = URI.escape(postdata, "!*'();:@&=+$,/?%#[]")
	data = "text=#{postdata}&lang=#{lang}&expire=-1&password=#{pass}&title=#{title}"
	resp, data = https.post("/paste/new", data, {'Content-Type'=> 'application/x-www-form-urlencoded'})
	case resp
	  when Net::HTTPSuccess     then return "Failed to post to ghostbin :("
	  when Net::HTTPRedirection then return "https://ghostbin.com#{resp['location']}"
	  else
	    return resp.error!
	  end
end

def usage
	puts "Usage: ghostbin.rb -f [file_path] -l [language] -p [password] -t [title]"
	puts "Usage: ghostbin.rb -qa"
	exit
end

if ARGV.length == 0
	usage()
end

params = ARGV.getopts("f:s:l:p:t:h","qa","help")

if params['h'] || params['help']
	usage()
end

if params['qa']
	file = ""
	while !File.exist?(file)
		print "[Ghostbin.rb] File: "
		file = gets.chomp
	end
	print "[Ghostbin.rb] Language[text]: "
	lang = gets.chomp
	print "[Ghostbin.rb] Password[none]: "
	password = gets.chomp
	print "[Ghostbin.rb] Title[none]: "
	title = gets.chomp
	puts postToGhostbin(file,lang,password,title)
	exit
end

file = params['f']
string = params['s']
if file && string
	puts "I am not certified to decide whether to use the string or the file you provided ;)"
	exit
end

password = params['p']
title = params['t']
lang = params['l']

url = ""
if file
	file = File.expand_path(file)
	unless File.exist?(file)
		puts "File does not exist. Please specify a valid path"
		exit
	end
	unless File.readable?(file)
		puts "File is not readable. Please make sure you have read permissions"
		exit
	end
	url = postToGhostbin(File.read(file),lang,password,title)
elsif string
	url = postToGhostbin(string,lang,password,title)
else
	url = "I need either a -s STRING or a -f FILE_PATH. Thanks :)"
end

puts url