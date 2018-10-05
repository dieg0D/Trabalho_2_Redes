require 'socket'                 

conClient = TCPServer.open(2000)
clientes = []
message = ""
#class Client
    
 #   attr_reader :client

#    def initialize(acc)
#        @client = acc
#    end

#end

puts "Servidor inicializado...."
quit = " "
while true                            
    cl = conClient.accept
    unless clientes.include?(cl)
        clientes << cl
        cl.puts "Bem vindo ao chat meu parça"
    else
        puts "Entrei no ELSE"
        message = cl.recvfrom(10000)
        puts message
        clientes.each do |cls|
            if cls != cl 
                cls.puts(Time.now.ctime)   
                cls.puts message
            end    
        end   
    end
end