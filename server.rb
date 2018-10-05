require 'socket'                 

server = TCPServer.open(2000)
clientes = []
message = ""
class Client
    
    attr_reader :client

    def initialize(acc)
        @client = acc
    end

end


loop {                           
    message = server.accept.gets
    cl = Client.new(server.accept)
    
    unless clientes.include?(cl)
        clientes << cl
        cl.client.puts "Bem vindo ao chat meu parça"
    else
        puts message
        clientes.each do |cls|
            if cls.client != cl.client 
                cls.client.puts(Time.now.ctime)   
                cls.client.puts message
            end    
        end   
    end
}