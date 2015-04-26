# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

#works
def read (filename, start_pos, length)
  aFile = aFile = File.new(filename, "r")
  if aFile
    content = aFile.sysread(length)
    puts content
  else
    puts "Unable to open file!"
  end
end

def write(filename, start_pos, message)
  aFile = File.new("File2.txt", "r+")
  if aFile
     aFile.syswrite(message)
  else
     puts "Unable to open file!"
  end
end

def readlines(filename, start_pos, num_lines)
  arr = IO.readlines("File1.txt")
  for i in 0..num_lines-1
  puts arr[i]
  end
end

#read("file1.txt",0,20)
#write("file2.txt",0, "testing")
#readlines("file1.txt",0, 5)

# reads and prints file line by line
#arr = IO.readlines("File1.txt")
#puts arr[0]
#puts arr[1]

class Client 
  def initialize
    #might include port number
  end
end

require 'socket'      # Sockets are in standard library
hostname = 'localhost'
port = 8000

s = TCPSocket.open(hostname, port)

file = open('decache.txt', "rb")
	fileContent = file.read
  s.puts("CACHE:\ndecache.txt")
	s.puts(fileContent)
	s.close