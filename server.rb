require 'socket'                 

server = TCPServer.open(2000)
server.listen(5)
clientes = []

message = ""
class Client
    
    attr_reader :client

    def initialize(acc)
        @client = acc
    end

end


loop {
    begin
        client = server.accept_nonblock
        clientes << client
    rescue IO::WaitReadable, Errno::EINTR
    end 
    puts clientes.length
    sleep(1)
    clientes.each do |cls|
        cls.puts(Time.now.ctime)  
        cls.puts("Closing the connection. Bye!")
        puts "teste do diego" 
    end
 
 }
 