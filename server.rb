require 'socket'                 

server = TCPServer.open(2000)
clientes = []
client = ""
message = ""


class Client
    
    attr_reader :client

    def initialize(acc)
        @client = acc
    end

end

puts "Server iniciado!"
loop {
    if clientes != []
        system("stty raw -echo")
        message = clientes[0].read_nonblock(10000) rescue nil
        system("stty -raw echo")
    end    
    begin
        client = server.accept_nonblock
        unless clientes.include?(client)
            clientes << client
            client.puts "Bem vindo ao chat meu parça"
            puts "#{client} as #{Time.now.strftime("%H:%M")} : Entrou no canal "
        end
    rescue IO::WaitReadable, Errno::EINTR
    end
    puts "#{Time.now.strftime("%H:%M")} #{client} disse: #{message}"
    clientes.each do |cls|
        cls.puts message
    end
    sleep(2)
 }
 