
# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'socket'                 
require 'thread'

PortNumber = 6000;

class Server                                                
  attr_accessor :socket, :IsOpen                           
  def initialize()                  
    @socket = TCPServer.open(PortNumber)
    @IsOpen = true
  end
end

def get_fid(key, hashmap)
  #if (hashmap.has_value?name)
  return(hashmap.fetch(key))
 # else fid = 0
 # end
  #return fid
end

def add_to_directory(key, answer, hashmap)
  hashmap.add(key, answer)
  return 1;
end

#create work queue and server
IPAddress = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
server = Server.new()
work_q = Queue.new

# maps user file names to server:filenames
# at the moment there is only one file server, so all files are on
# server 1
directory = {"file1" => "1:file1.txt",
            "file2" => "1:file2.txt",
            "file3" => "1:file3.txt"                     
          }

# 5 threads serve the clients
workers = (0...5).map do
  Thread.new do
    begin   
      while server.IsOpen
        if work_q.length > 0
          client = work_q.pop               
          
          # SERVE CLIENT
       #   while(true)
          line = client.gets
            #1 HELO 
          if (line.include?("HELO"))
            client.puts "HELO text\nIP:[#{IPAddress}]\nPort:[#{PortNumber}]\nStudentID:[10303365]"

          #2 Kill service
          elsif (line == "KILL_SERVICE\n")
            puts "Kill servive received"
            server.socket.close        
            server.IsOpen = false

          elsif (line.match(/^RESOLVE:/))
            puts "resolve"
            filename = client.gets.chomp
            puts filename
            puts(directory.fetch(filename))
            client.puts(directory.fetch(filename))
            puts "done"             
          else
            puts "unknown command"
          end                      
            
          client.close 
          puts "client closed"
      #  end 
     #   client.close 
      #  puts "client closed"
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
