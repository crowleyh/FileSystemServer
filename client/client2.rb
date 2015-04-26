# client

def is_valid(filename)
  if (filename == "file1" || filename == "file2" || filename == "file3")
    return true
  else
    return false
  end
end


require 'socket'      # Sockets are in standard library
hostname = 'localhost'

CPport = 5000

s = TCPSocket.open(hostname, CPport)

puts "Welcome. This is the client"

while (true)
puts "to open a file, enter: O. close: C, read: R, write:W"
input = gets.chomp

# open file
if (input == "O")
  puts "the available files are file1, file2 and file3"
  puts "please enter the name of the file you wish to access"
  filename = gets.chomp 
  if (is_valid(filename))
    s.puts("OPEN:\n")
    s.puts filename
    s.puts("\n")
    while line = s.gets # Read lines from socket
      if (line.chomp == "DONE")
        break
      else
        puts line         # and print them
      end
    end
  else
    puts "Invalid filename"
  end


# DECACHE
elsif (input == "C")
  puts "the available files are file1, file2 and file3"
  puts "please enter the name of the file you wish to access"
  filename = gets.chomp
  if (is_valid(filename))
    "decaching file1.txt"
    s.puts("CLOSE:\n")
    s.puts(filename)
    s.puts("\n")
    while line = s.gets # Read lines from socket
      if (line.chomp == "DONE")
        break
      else
        puts line         # and print them
      end
    end
  else
    puts "Invalid filename"
  end
  s.close
  
   #decache("file1.txt",s)

elsif (input == "R")
  puts "the available files are file1, file2 and file3"
  puts "please enter the name of the file you wish to access"
  filename = gets.chomp
  if (is_valid(filename))
    puts "enter number of characters to read"
    num_chars = gets.chomp
    s.puts("READ:\n")
    s.puts(filename)
    s.puts (num_chars)
    while line = s.gets # Read lines from socket
      if (line.chomp == "DONE")
        break
      else
        puts line         # and print them
      end
    end
    else puts "Invalid filemname"
    end
    
elsif (input == "W")
  puts "the available files are file1, file2 and file3"
  puts "please enter the name of the file you wish to write to"
  filename = gets.chomp
  if (is_valid(filename))
    puts "enter message to write"
    message = gets.chomp
    s.puts("WRITE:\n")
    s.puts(filename)
    s.puts (message)
    while line = s.gets # Read lines from socket
      if (line.chomp == "DONE")
        break
      else
        puts line         # and print them
      end
    end
  else 
    puts "Invalid filename"
  end
end
end
