require 'socket'                 

server = TCPServer.open(2000)
clientes = []
cl_ms = {}
client = ""
mensagem = ""


class Client
    
    attr_reader :client

    def initialize(client)
        @client = client
        @nick = "usr#{clientes.length}"
        @canal = 0
    end

end

puts "Server iniciado!"
loop {
    begin
        client = Client.new(server.accept_nonblock)
        unless clientes.include?(client)
            clientes << client
            client.puts "Bem vindo ao chat meu parça"
            puts "#{Time.now.strftime("%H:%M")} #{client} Entrou no canal! "
        end 
    rescue IO::WaitReadable, Errno::EINTR
    end

    if clientes != []
        clientes.each do |cls|
            system("stty echo")
            mensagem = cls.read_nonblock(10000) rescue nil
            system("stty echo")
            cl_ms[cls] = mensagem
            if mensagem.to_s.tr("\n","") != ""
                puts "#{Time.now.strftime("%H:%M")} #{cls} disse: #{mensagem}"
                clientes.each do |aux|
                    if aux != cls
                        aux.puts "#{cls} disse :  #{cl_ms[cls].to_s.tr("\n","")}"
                    end
                end
            end   
        end   
    end  

    sleep(1)
 }
 