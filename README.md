# FileSystemServer

I have implemented the following components:
- Distributed Transparent File Access (FileSystemServer.rb, port 8000)
- Directory Service (DirectoryServer.rb port 6000)
- Caching (Upload/download model. Files are cached at the proxy server when opened, before reading/writing. When a file is closed, it is written back to the file server)
- Lock Service (LockServer.rb port 6500)

The client proxy (client_proxy.rb) is used to communicate between the client (client2.rb) and the various servers.

To test please run FileSystemServer.rb, DirectoryServer.rb, LockServer.rb and client_proxy.rb. Then run client2.rb. Instructions will be provided by client 2 to open a file (enter 'O'), close, read, write etc. using the command line. 

At the moment the only available files are file1, file2, and file3 on the file system server. 

Limitations:
1) The lock server keeps the connection open with the client proxy from when a file is opened until it is closed, to allow the thread to unlock and then lock the semaphore. This limits the number of files that can be opened at any one time to 5 (the number of threads in the lock server)

2) The directory server maps filename => server:filename e.g. "file1" => "1:file1.txt". Each server acts as a directry (flat architecture). At the moment there is only one server and three files, so the server is always server 1. 
