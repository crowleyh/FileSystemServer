# AFS (upload/download) style file system

require 'socket'                 
require 'thread'


PortNumber = 5000;
hostname = 'localhost';


# File system server ports. Each file server acts as its own directory
#(flat architecture)
FSSport_1 = 8000; # all files currently stored on FS1
FSSport_2 = 8001; # in future, may have additional files stored here 

FSSport = FSSport_1; # by default. If we had files on other servers,
# once the filename was resolved FSS_port could be set to FSSport_2, 3 etc.

DSport = 6000; # directory server port
LSport = 6500; # lock server port


class Server                                                
  attr_accessor :socket, :IsOpen                           
  def initialize()                  
    @socket = TCPServer.open(PortNumber)
    @IsOpen = true
  end
end

# read file (from start of file
def read (filename, length, client)
  afile = File.new(filename.to_s, "r")
  if afile
    content = afile.sysread(length)
    puts content
    client.puts content
  else
    client.puts "Unable to read file!"
  end
end

# write to file (from start of file)
def write(filename, message, client)
  afile = File.new(filename, "r+")
  if afile
     afile.syswrite(message)
     client.puts("Changes made to "+ filename)
  else
     client.puts "Unable to write to file!"
  end
end

# caches the file at the client proxy
def cache_at_client(filename,s)
  s.puts("CACHE:\n")
  s.puts(filename)
  s.puts("\n")
  data = s.read
	dest_file = File.open(filename, 'wb')
	dest_file.print(data)
	dest_file.close
end

# save file back to the file server
def decache_at_server (filename, s) 
  file = open(filename, "rb")
  file_content = file.read
  s.puts("DECACHE:\n")
  s.puts(filename)
  s.puts ("\n")
  s.puts(file_content)
end

# resolve filename at directory server
def resolve_filename (filename, port)
  s = TCPSocket.open('localhost', port)
  s.puts("RESOLVE:\n")
  s.puts(filename)
  s.puts("\n")
  r = s.gets
  values = r.split(":")
  server = values[0]
  file = values[1].strip
  s.close
  return server, file
end

# lock file at lock server
def lock_file2(filename, s)
  s.puts("LOCK:\n")
  s.puts(filename)
  s.puts("\n")
  r = s.gets.chomp
  return r
end

# unlock file after use at lock server
def  unlock_file2 (filename, s)
  s.puts("UNLOCK:\n")
  s.puts(filename)
  s.puts("\n")
  r = s.gets.chomp
  return r
end

#create work queue and server
IPAddress = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
server = Server.new()
work_q = Queue.new

workers = (0...2).map do
  Thread.new do
    begin   
      while server.IsOpen
        if work_q.length > 0
          client = work_q.pop 
          ls_socket = TCPSocket.open('localhost', LSport)
     
      # SERVE CLIENT
        while(true)
          line = client.gets
          #1 HELO 
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
            filename = client.gets.chomp    # chomp removes newline
            puts filename
            num_chars = client.gets.chomp.to_i
            puts num_chars
            server_num,server_file_name = resolve_filename(filename, DSport)
            if (File.exists?(server_file_name))
              read(server_file_name,num_chars,client)
              client.puts("DONE")
            else
              client.puts "File must be opened before reading"
              client.puts("DONE")
            end
            
          # OPEN
          elsif(line.match(/^OPEN:/))
            puts "Open message received"
            filename = client.gets.chomp 
            puts("Requesting Access to file" + filename + "from Lock Server")
            response = lock_file2(filename, ls_socket)
            if (response == "ok")
              puts ("Access granted, resolving filename at Directory Server")
              server_num,server_file_name = resolve_filename(filename, DSport)
              s = TCPSocket.open('localhost', FSSport)
              puts "Filename resolved, requesting file from File Server"
              cache_at_client(server_file_name, s)
              s.close
              puts("File: " +filename + "is now open")
              client.puts("File: " +filename + " is now open")
              client.puts("DONE")
            else
              client.puts "Sorry, the file you requested is in use. Please try again later"
              client.puts("DONE")
            end

          #4 Close - does nothing in NFS
          elsif (line.match(/^CLOSE:/))
            puts "Close message received"
            filename = client.gets.chomp
            puts "Unlocking file at Lock Server"
            r = unlock_file2(filename, ls_socket)
            puts r
            puts "File unlocked, resolving file name with Directory Server"
            server_num,server_file_name = resolve_filename(filename, DSport)
            s = TCPSocket.open('localhost', FSSport)
            decache_at_server(server_file_name, s) 
            s.close
            puts("File: " +filename + " is now closed") 
            client.puts ("File: "+ filename +" is now closed")
            client.puts("DONE")
            client.close
            break

          #6 Write - important  
          elsif (line.match(/^WRITE:/))
            puts "Write message received for file:"
            filename = client.gets.chomp    # chomp removes newline
            puts filename
            message = client.gets.chomp
            puts "The message is:"
            puts message
            puts "Resolving filename"
            server_num,server_file_name = resolve_filename(filename, DSport)
            if (File.exists?(server_file_name))
              write(server_file_name,message,client)
              client.puts "File written to "
              client.puts("DONE")
            else
              client.puts "File must be opened before writing "
              client.puts("DONE")
            end             

          # disconnect
          elsif (line.match(/^DISCONNECT:/))
            client.close  
            break
          end  

          end  # end while true   
          client.close
          break
        end                                                
      end #end while sever isOpen
      
      rescue ThreadError
    end
  end
end; 


#main loop continues to accept clients and push them onto the queue
while server.IsOpen                                                                          
  work_q.push(server.socket.accept)  
end
workers.map(&:join);    #stop all threads when they have completed serving                   
                                                        
   


