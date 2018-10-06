require 'socket'                 

server = TCPServer.open(2000)
clientes = []
cl_ms = {}
client = ""
mensagem = ""


class Client
    
    attr_accessor :client, :nick, :canal, :usuario 

    def initialize(client)
        @client = client
        @nick = "USR"
        @canal = 0
        @usuario = ""
    end

end

puts "Server iniciado!"
loop {
    begin
        client = Client.new(server.accept_nonblock)
        unless clientes.include?(client)
            clientes << client
            client.client.puts "Bem vindo ao chat meu parça"
            puts "#{Time.now.strftime("%H:%M")} #{client.client} Entrou no canal! "
        end 
    rescue IO::WaitReadable, Errno::EINTR
    end

    if clientes != []
        clientes.each do |cls|
            system("stty echo")
            mensagem = cls.client.read_nonblock(10000) rescue nil
            system("stty echo")
            cl_ms[cls.client] = mensagem
            if mensagem.to_s.tr("\n","") != ""
                puts "#{Time.now.strftime("%H:%M")} #{cls.client} disse: #{mensagem}"
                clientes.each do |aux|
                    if aux != cls
                        aux.client.puts "#{cls.client} disse :  #{cl_ms[cls.client].to_s.tr("\n","")}"
                    end
                end
            end   
        end   
    end  

    sleep(1)
 }

