# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require 'find'
puts "Hello World"
 puts(File.exists?('client.rb')) # works
  puts(File.exists?("client.rb")) # works


puts(File.exists?('file1.txt'))

filename = "heather"
  data = "helloooooooo my name is heather"
	dest_file = File.open(filename, 'wb')
	dest_file.print(data)
	dest_file.close