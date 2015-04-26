require 'socket'                 
require 'thread'

PortNumber = 6500;

class Server                                                
  attr_accessor :socket, :IsOpen                           
  def initialize()                  
    @socket = TCPServer.open(PortNumber)
    @IsOpen = true
  end
end


#create work queue and server
IPAddress = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
#PortNumber= ARGV[0]           take port number as argument from command line
server = Server.new()
work_q = Queue.new

# 1 semaphore for each file that the lock server knows about
file1_semaphore = Mutex.new # corresponds to "file1"
file2_semaphore = Mutex.new # corresponds to "file2"
file3_semaphore = Mutex.new # "file3"

# 5 threads serve the clients
workers = (0...5).map do
  Thread.new do
    begin   
      while server.IsOpen
        if work_q.length > 0
          client = work_q.pop                        
          
          puts "File 1 locked :" 
          puts file1_semaphore.locked?
          puts "File 2 locked :" 
          puts file2_semaphore.locked?
          puts "File 3 locked :" 
          puts file3_semaphore.locked?
          puts "................................."
          
          while(true)
          # SERVE CLIENT
            line = client.gets
            if (line.include?("HELO"))
              client.puts "HELO text\nIP:[#{IPAddress}]\nPort:[#{PortNumber}]\nStudentID:[10303365]"
              client.close
             
            #2 Kill service
            elsif (line == "KILL_SERVICE\n")
              puts "Kill servive received"
              server.socket.close              
              server.IsOpen = false
            
            #3 READ 
            elsif (line.match(/^LOCK:/))
              puts "LOCK message received for file:"
              filename = client.gets.chomp    # chomp removes newline 
              if (filename== "file1")
                if (!file1_semaphore.locked?)
                  file1_semaphore.lock
                  client.puts("ok")                 
                else
                  puts "file1 already in use"
                  client.puts("no")                 
                end
              elsif (filename == "file2")
                if (!file2_semaphore.locked?)
                  file2_semaphore.lock
                  client.puts("ok")
                else
                  puts "file2 already in use"
                  client.puts("no")                 
                end
              elsif (filename == "file3")
                if (!file3_semaphore.locked?)
                  file3_semaphore.lock
                  client.puts("ok")
                else
                  puts "file3 already in use"
                  client.puts("no")                 
                end  
              else
                puts "unknown filename"               
              end             
  
            #4 Close - does nothing in NFS
            elsif (line.match(/^UNLOCK:/))
              puts "UNLOCK message received for file:"
              filename = client.gets.chomp   
              if (filename == "file1")
                  puts "file1"
                  if(file1_semaphore.locked?)
                    file1_semaphore.unlock
                  end
                  client.puts("ok")
                  puts "File unlocked"
              elsif (filename == "file2")
                  puts "file2"
                  if(file2_semaphore.locked?)
                    file2_semaphore.unlock
                  end
                  client.puts("ok")
              elsif (filename == "file3")
                  puts "file3"
                  if(file3_semaphore.locked?)
                    file3_semaphore.unlock                   
                  end
                  client.puts("ok")
              else
                client.puts "unknown filename"
              end
              client.close
            
            end      
        
            puts "................................."   
            puts "File 1 locked :" 
            puts file1_semaphore.locked?
            puts "File 2 locked :" 
            puts file2_semaphore.locked?
            puts "File 3 locked :" 
            puts file3_semaphore.locked?
            puts "................................."
          end # end of while true
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
