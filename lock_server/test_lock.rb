
class Client 
  def initialize
    #might include port number
  end
end

require 'socket'      # Sockets are in standard library
hostname = 'localhost'
port = 6500;


s = TCPSocket.open(hostname, port)
#s.puts("HELO text\n")
s.puts("UNLOCK:\n")
s.puts("file1")
s.puts("\n")
puts(s.gets)


s.close               # Close the socket when done

