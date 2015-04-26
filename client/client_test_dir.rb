# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.


class Client 
  def initialize
    #might include port number
  end
end

require 'socket'      # Sockets are in standard library
hostname = 'localhost'
port = 6000;


s = TCPSocket.open(hostname, port)
s.puts("RESOLVE:\n")
s.puts("file1")
s.puts("\n")
r = s.gets
values = r.split(":")
puts values[0]

server = values[0]
filename = values[1]

puts ("Filename: " + filename)
puts ("server:   "+ server)

s.close               # Close the socket when done

