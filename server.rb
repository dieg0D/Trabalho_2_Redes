require 'socket'                 

server = TCPServer.open(2000)
clientes = []
cl_ms = {}
client = ""
mensagem = ""
canais = ["General", "Séries", "Músicas", "Jogos", "Filmes"]


class Client
    
    attr_accessor :client, :nick, :canal, :usuario 
    @@count_users = 0
    def initialize(client)
        @client = client
        @nick = "USR#{@@count_users}"
        @canal = 1
        @usuario = ""
        @@count_users = @@count_users+1
    end

    def listar(clientes, canais)
        @client.puts 
        @canais.each_with_index do |cn, index|
            @client.puts "Canal {#{index+1}} - #{cn} #{contar(clientes, index+1)} pessoas conectadas "
        end
        @client.puts 
    end
    
    private

        def contar(clientes, num)
            count=0
            clientes.each do |usr|
                if usr.canal == num
                    count=count+1
                end
            end
            count
        end
end

def parser(msg,client,clientes,canais)
    ivet = msg.to_s.split(' ',2)
    comando = ivet[0]
    aux = ivet[1]
    flag =false

    case comando
    when "NICK"
        client.nick= aux.tr("\n","")
        flag= true
    when "USUARIO"
        client.usuario = aux.tr("\n","")
        flag=true
    when "LISTAR"
        client.listar(clientes,canais)
        flag=true 
    when "SAIR"
        clientes.each do |cls|
            if cls.canal == client.canal
                cls.client.puts "#{client.nick} saiu do canal"
            end
        end
        client.client.puts "Você foi desconectado aperte ENTER para sair!!!!"
        client.client.close
        clientes.delete(client)
        flag=true
    when "SAIRC"
        clientes.each do |cls|
            if cls.canal == client.canal
                cls.client.puts "#{client.nick} saiu do canal"
            end
        end
        client.client.canal=1
        flag=true
    when "ENTRAR"
        client.canal=aux.to_i
        clientes.each do |cls|
            if cls.canal == client.canal
                if cls.client == client.client
                    cls.client.puts "Você entrou no canal #{canais[aux.to_i-1]}"
                else
                    cls.client.puts "#{client.nick} entrou no canal"
                end

            end
        end
        flag=true
    when"COMANDOS"
        client.client.puts "Comandos aceitos pelo chat: NICK, USUARIO, LISTAR, SAIR, SAIRC, ENTRAR"
        client.client.puts "NICK altere seu apelido" 
        client.client.puts "USUARIO altere seu nome"
        client.client.puts "LISTAR lista dos canais disponiveis"
        client.client.puts "SAIR finalizar a sessao do cliente"
        client.client.puts "SAIRC sair do canal atual"
        client.client.puts "ENTRAR entrar em um canal"
        client.client.puts "COMANDOS entrar em um canal"
        client.client.puts "PS: lembre-se, comandos em maiusculo rsrsrs"
        client.client.puts
        flag=true
    else
    end

    flag
end    

puts "Server iniciado!"
loop {
    begin
        client = Client.new(server.accept_nonblock)
        unless clientes.include?(client)
            clientes << client
            client.client.puts "##################################"
            client.client.puts "#  Bem vindo ao chat meu parça   #"
            client.client.puts "#  Segue abaixo as instruções    #"
            client.client.puts "##################################"
            client.client.puts
            client.client.puts "Comandos aceitos pelo chat: NICK, USUARIO, LISTAR, SAIR, SAIRC, ENTRAR"
            client.client.puts "NICK altere seu apelido" 
            client.client.puts "USUARIO altere seu nome"
            client.client.puts "LISTAR lista dos canais disponiveis"
            client.client.puts "SAIR finalizar a sessao do cliente"
            client.client.puts "SAIRC sair do canal atual"
            client.client.puts "ENTRAR entrar em um canal"
            client.client.puts "COMANDOS entrar em um canal"
            client.client.puts "PS: lembre-se, comandos em maiusculo rsrsrs"
            client.client.puts
            client.client.puts "OOHHHH notamos que vc chegou agora!!!!!"
            client.client.puts "Para vc começar a conversar com outras pessoas utilize o comando USUARIO"
            client.client.puts 
            puts "#{Time.now.strftime("%H:%M")} #{client.nick} Entrou no canal! "
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
                puts "#{Time.now.strftime("%H:%M")} #{cls.nick} disse: #{mensagem}"
                clientes.each do |aux|
                    if aux != cls && !parser(mensagem,cls,clientes,canais) && aux.canal == cls.canal
                        aux.client.puts "#{Time.now.strftime("%H:%M")} #{cls.nick} disse :  #{cl_ms[cls.client].to_s.tr("\n","")}"
                    end
                end
            end   
        end   
    end  

    sleep(1)
 }
 