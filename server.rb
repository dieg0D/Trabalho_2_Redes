require 'socket'                 

server = TCPServer.open(2000)
clientes = []

class Client
    
    attr_reader :client

    def initialize(acc)
        @client = acc
    end

end


loop {                           
    cl = Client.new(server.accept)

    unless clientes.include?(cl)
        clientes << cl
    end

    clientes.each do |cls|
        cls.client.puts(Time.now.ctime)   
        cls.client.puts "Bem vindo ao chat meu parça"
    end              
}