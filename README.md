http_info
=========

Get http titles and server headers

Author: Devin Ertel
Filename: http_info.rb 
Description: Takes in a text file of ip:port and will make a request to grab the title and server header.
useful for taking in nmap/nessus parsed data to quickly gain info on  potential HTTP targets with their server and titles.

USAGE: ruby http_info.rb <FILENAME>

File Input Format:
ip:port
ip:port

Todo: 
  - better https check
  - add timeout parameter 
  - rewrite with httparty or faraday
