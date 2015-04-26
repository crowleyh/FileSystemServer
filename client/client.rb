# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.


class Client 
  def initialize
    #might include port number
  end
end

def cache (filename,s)
data = s.read
	destFile = File.open(filename, 'wb')
	destFile.print data
	destFile.close
end

require 'socket'      # Sockets are in standard library
hostname = 'localhost'
port = 5000

s = TCPSocket.open(hostname, port)

 
#s.puts("KILL_SERVICE\n")
#s.puts("READ:\n")
#s.puts("READ:\nFile1.txt\n0\n100")
#sleep(4)
#s.puts("CACHE:\nFile1.txt\n0\nheather crowley 1991")
#s.puts("CLOSE:\n")
#s.puts("WRITE:\n")
#s.puts("HELO there \n")
#s.puts("KILL_SERVICE\n")

#def post_message(s)
#  s.puts ("LEAVE_CHATROOM: 0 \nJOIN_ID: 0\nCLIENT_NAME: Heather\nMESSAGE: Hi there")
#end

#s.puts("JOIN_CHATROOM: [chatroom name]\nCLIENT_IP: [IP Address of client if UDP | 0 if TCP] \nPORT: [port number of client if UDP | 0 if TCP] \nCLIENT_NAME: [string Handle to identifier client user] )")
#s.puts("LEAVE_CHATROOM: name \nJOIN_ID: 7 \nCLIENT_NAME: Heather")

#puts "going to sleep"
#sleep(4);
#puts "awake"
#post_message(s)
s.puts("OPEN:\nfile1\n")
#cache("File1.txt",s )
  
#while line = s.gets
 # puts line.chop
#end

  

s.close               # Close the socket when done
