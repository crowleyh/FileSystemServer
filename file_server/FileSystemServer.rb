# AFS (upload/download) style file system

require 'socket'                 
require 'thread'


PortNumber = 8000;

class Server                                                
  attr_accessor :socket, :IsOpen                           
  def initialize()                  
    @socket = TCPServer.open(PortNumber)
    @IsOpen = true
  end
end

def read (filename, start_pos, length, client)
  afile = File.new(filename.to_s, "r")
  if afile
    content = afile.sysread(length)
    client.puts content
  else
    client.puts "Unable to open file!"
  end
end

def write(filename, start_pos, message, client)
  afile = File.new("File2.txt", "r+")
  if afile
     afile.syswrite(message)
     client.puts("Changes made to "+ filename)
  else
     client.puts "Unable to open file!"
  end
end

# not currently used bu could be useful later
def readlines(filename, start_pos, num_lines, client)
  arr = IO.readlines("File1.txt")
  for i in 0..num_lines-1
  client.puts arr[i]
  end
end

#create work queue and server
IPAddress = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
#PortNumber= ARGV[0]           take port number as argument from command line
server = Server.new()
work_q = Queue.new


# 5 threads serve the clients
workers = (0...5).map do
  Thread.new do
    begin   
      while server.IsOpen
        if work_q.length > 0
          client = work_q.pop               
          
          # SERVE CLIENT
          while(true)
            line = client.gets
            #1 HELO Message NOT WORKING!!
            if (line.include?("HELO"))
              client.puts "HELO text\nIP:[#{IPAddress}]\nPort:[#{PortNumber}]\nStudentID:[10303365]"
              puts "GOT IT"
             
            #2 Kill service
            elsif (line == "KILL_SERVICE\n")
              puts "Kill servive received"
              server.socket.close              #this needs to be fixed- atm it just crashes
              server.IsOpen = false
            
            #3 READ 
            elsif (line.match(/^READ:/))
              puts "Read message received for file:"
              filename = client.gets.chomp    # chomp removes nerlinw 
              posn = client.gets.chomp.to_i
              num_chars = client.gets.chomp.to_i
              read(filename,0,num_chars,client)
  
            #4 Close - does nothing in NFS
            elsif (line.match(/^CLOSE:/))
              puts "Close message received"
              #timestamp?
            
            #5 OPEN - does nothing in NFS
            elsif (line.match(/^OPEN:/))
              puts "open recevied"
              puts "open complete (open does nothing)"             
            
            #6 Write - important  
            elsif (line.match(/^WRITE:/))
              puts "write message received"
              filename = client.gets.chomp    # chomp removes nerlinw 
              posn = client.gets.chomp.to_i
              message = client.gets.chomp
              write(filename, posn, message, client)
              puts "write complete"
              
            # works!
            elsif (line.match(/^CACHE:/))
              puts "cache request received at FSS"
              filename = client.gets.chomp
              puts "filename received:"
              puts(filename)
              file = open(filename, "rb")
              fileContent = file.read
	            client.puts(fileContent)
              puts "cache request complete"
            
            # works!
            elsif (line.match(/^DECACHE:/))
              puts "de-cache request received"
              filename = client.gets.chomp
              data = client.read
              destFile = File.open(filename, 'wb')
              destFile.print data
              destFile.close  
              puts "de-cache request complete"
              
            # disconnect
            elsif (line.match(/^DISCONNECT:/))
              client.close  
            
            else
              puts "no match"
            end          
        
        client.close 
        puts "client closed"
        end        
        end                                                
      end
    
    rescue ThreadError
    end
  end
end; 


#main loop continues to accept clients and push them onto the queue
while server.IsOpen                                                                          
  work_q.push(server.socket.accept)  
end
workers.map(&:join);    #stop all threads when they have completed serving              
