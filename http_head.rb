#Author: Devin Ertel
#Filename: http_info.rb 
#Description: Takes in a text file of ip:port and will make a request to grab the title and server header.
#useful for taking in nmap/nessus parsed data to quickly gain info on  potential HTTP targets with their server and titles.
#Todo: 
# - better https check, 
# - add timeout parameter 
# - rewrite with httparty or faraday
#

require 'net/http'
require 'uri'
require 'net/https'
require 'logger'

#file supplied from argument
input_file = ARGV[0]

#check argument is supplied
unless ARGV.length == 1
  puts "Usage: http_info.rb <FILENAME>"
  puts "Provide list of IP:PORT\n"
  exit
end

#Open file and loop though each line
File.open(input_file).each_line{|target|

	#Remove newlines
	target.chomp!
	#split out host and port
	host, port = target.chomp.split(':', 2)

	#if port is not set, default to 80
	if port.nil?
		port=80
	end

	#check host and port exist and error out if not
	if host && port
	
		#Parse host and port into URI
		uri = URI.parse("http://#{host}:#{port}")
	
		#Setup HTTP	
			http = Net::HTTP.new(uri.host, uri.port)
			http.open_timeout = 2 # in seconds
			http.read_timeout = 2 # in seconds
		
			#hack to connect via https for comomon https ports
			if uri.port == 443 || uri.port == 8443
			#SSL enable
			http.use_ssl = true
			end
		
			#logger file - useful for debugging and getting more info on host
			http.set_debug_output(Logger.new("http_info.log"))
		
			#Setup exception handeling for connection refused and reset. Reset will attempt to connect again via SSL
			#Other exceptions: Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       		#Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError 
			begin
				#Setup Get request, grab response body
				request = Net::HTTP::Get.new(uri.request_uri)
				response = http.request(request)
				body= response.body
			rescue 	Errno::ECONNREFUSED
				p "Connection refused to #{host}"
				next
			rescue Errno::ECONNRESET
				p "Connection Reset on #{host}, Trying SSL"
				http.use_ssl = true
				retry
			end

			#grab server header
			server = response["Server"] 
		
			#regex any character , case insensitive <title> match
			#old regex - title = response.body.match("<title>(.*)<\/title>")
			title = /(?<=<title>).*(?=<\/title>)/i.match(body)

			#Display webserver data
			puts "HOST: #{host}:#{port} TITLE: #{title}  HEADER: #{server}" 
			else
			p "Error in supplied list on line"
	end
}
