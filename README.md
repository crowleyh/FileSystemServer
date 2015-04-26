# FileSystemServer


I have implemented the following components:
- Distributed Transparent File Access (FileSystemServer.rb, port 8000)
- Directory Service (DirectoryService.rb port 6000)
- Caching (Upload/ download model)
- Lock Service (LockServer.rb port 6500)

The client proxy (client_proxy.rb) is used to communicate between the client (client2.rb) and the various servers.

To test please set all servers and client proxy running, then start client2. Instructions will be provided to open a file (enter 'O'), close, read, write etc. At the moment the only available files are file1, file2, and file3 on the file system server. 


