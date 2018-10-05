require 'socket'
include Socket::Constants

server = Socket.new(AF_INET, SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(2000, 'localhost')
server.bind(sockaddr)
server.listen(5)

clientes = []

loop {
    begin
        client_socket, client_addrinfo = server.accept_nonblock
        clientes << client_socket
    rescue IO::WaitReadable, Errno::EINTR
    
    end 
    sleep(1)
    clientes.each do |cls|
        cls.puts(Time.now.ctime)  
        cls.puts("Closing the connection. Bye!")
        puts "teste do diego" 
    end
 
 }
 