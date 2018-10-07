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
        @nick = "User#{@@count_users}"
        @canal = 0
        @usuario = ""
        @@count_users = @@count_users+1
    end

    def listar(clientes, canais)
        
        @client.puts 
        canais.each_with_index do |cn, index|
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

    if client.usuario == "" && comando != "USUARIO" && comando != "SAIR"
        comando = "ERROR"
    end    

    if client.usuario != "" && client.canal == 0 && comando != "SAIR" && comando != "LISTAR" && 
                                                    comando != "ENTRAR" && comando != "NICK" && 
                                                    comando != "USUARIO" && comando != "COMANDOS"  
        
        comando = "ERROR2"
    end    

    case comando
    when "NICK"
        igual = false
        if aux.tr("\n", "") == ""

                client.client.puts             
                client.client.puts "É preciso passar um parametro para NICK. Exemplo: NICK diego"            
                client.client.puts             
        else
            clientes.each do |cls|
                if aux.tr("\n","") == cls.nick && cls != client       
                    igual = true
                end
            end

            if igual == true

                client.client.puts 
                client.client.puts "Esse nick já está em uso por favor selecione outro!!!"
                client.client.puts 
            else
                clientes.each do |cls|
                    if cls.canal == client.canal
                        if cls != client
                            cls.client.puts "#{Time.now.strftime("%H:%M")} #{client.nick} teve seu nick alterado para #{aux.tr("\n","")}"
                        else
                            client.client.puts "#{Time.now.strftime("%H:%M")} Seu nick foi alterado de #{client.nick} para #{aux.tr("\n","")}"
                        end
                    end
                end
                 client.nick= aux.tr("\n","")

            end
        end
        flag= true
    when "USUARIO"
        if aux.tr("\n","")== "" || aux.tr("\n","")== nil
            client.client.puts 
            client.client.puts "É preciso passar um parametro para USUARIO. Exemplo: USUARIO breno"
            client.client.puts 
        else
            client.usuario = aux.tr("\n","")
            client.client.puts
            client.client.puts "Muito bem vc se cadastrou!"
            client.client.puts "utilize o comando LISTAR para ver os canais disponiveis"
            client.client.puts "E utilize o comando ENTRAR para entrar no canal desejado"
            client.client.puts 
        end
            flag=true
    when "LISTAR"
        client.listar(clientes,canais)

        client.client.puts 
        client.client.puts "Utilize o comando ENTRAR com o numero do canal para poder ir para ele"
        client.client.puts 
        flag=true 
    when "SAIR"
        clientes.each do |cls|
            if cls.canal == client.canal && client.canal != 0 
                if cls != client
                    cls.client.puts "#{Time.now.strftime("%H:%M")} #{client.nick} saiu do canal"
                else
                    client.client.puts "#{Time.now.strftime("%H:%M")} Você saiu do canal"
                end
            end
        end
        client.client.puts "#{Time.now.strftime("%H:%M")} Você foi desconectado aperte ENTER duas vezes para sair!!!!"
        client.client.close
        clientes.delete(client)
        flag=true
    when "SAIRC"
        clientes.each do |cls|
            if cls.canal == client.canal
                if cls != client
                    cls.client.puts "#{Time.now.strftime("%H:%M")} #{client.nick} saiu do canal"
                else
                    client.client.puts "#{Time.now.strftime("%H:%M")} Você saiu do canal"
                end
            end
        end
        client.canal = 0
        flag=false
    when "ENTRAR"
        if aux.to_i > 0 && aux.to_i <= 5 
            if aux.to_i == client.canal

                client.client.puts 
                client.client.puts "Você já está no canal selecionado"
                client.client.puts 
            else
                canalAnt = client.canal
                if canalAnt != 0
                    clientes.each do |cls|
                        if cls.canal == client.canal
                            if cls != client
                                cls.client.puts "#{Time.now.strftime("%H:%M")} #{client.nick} saiu do canal"
                            else
                                client.client.puts "#{Time.now.strftime("%H:%M")} Você trocou do canal #{canais[canalAnt-1]} para o canal #{canais[aux.to_i-1]}"    
                            end    
                        end
                    end        
                end    
                client.canal=aux.to_i
                clientes.each do |cls|
                    if cls.canal == client.canal
                        if cls != client
                            cls.client.puts "#{Time.now.strftime("%H:%M")} #{client.nick} entrou no canal"
                        else
                            client.client.puts "#{Time.now.strftime("%H:%M")} Você entrou no canal de #{canais[aux.to_i-1]}"
                        end
                    end
                end 
            end
        else
            client.client.puts 
            client.client.puts "O canal que foi digitado não existe"
            client.client.puts 
        end
        flag=true
    when "COMANDOS"
        client.client.puts "Comandos aceitos pelo chat: NICK, USUARIO, LISTAR, SAIR, SAIRC, ENTRAR, COMANDOS"
        client.client.puts
        client.client.puts "NICK altere seu apelido" 
        client.client.puts "USUARIO altere seu nome"
        client.client.puts "LISTAR lista os canais disponiveis"
        client.client.puts "SAIR finaliza a sessão "
        client.client.puts "SAIRC sair do canal atual"
        client.client.puts "ENTRAR entrar em um canal"
        client.client.puts "COMANDOS mostra os comandos "
        client.client.puts
        client.client.puts "PS: lembre-se, comandos em maiusculo rsrsrs"
        client.client.puts "PS1: Os comandos precisam estar separados por um espaço do seu argumento"
        client.client.puts
        flag=true
    when "ERROR"

        client.client.puts 
        client.client.puts "Para vc começar a conversar com outras pessoas utilize o comando USUARIO"
        client.client.puts 
        flag=true
    when "ERROR2"
        client.client.puts         
        client.client.puts "Você não está conectado"
        client.client.puts "utilize o comando LISTAR para ver os canais disponiveis"
        client.client.puts "E utilize o comando ENTRAR para entrar no canal desejado"
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
            client.client.puts "                    ####################################"
            client.client.puts "                    #        Bem vindo ao chat         #"
            client.client.puts "                    #    Segue abaixo as instruções    #"
            client.client.puts "                    ####################################"
            client.client.puts
            client.client.puts "Comandos aceitos pelo chat: NICK, USUARIO, LISTAR, SAIR, SAIRC, ENTRAR, COMANDOS"
            client.client.puts
            client.client.puts "NICK altere seu apelido" 
            client.client.puts "USUARIO altere seu nome"
            client.client.puts "LISTAR lista os canais disponiveis"
            client.client.puts "SAIR finaliza a sessão "
            client.client.puts "SAIRC sair do canal atual"
            client.client.puts "ENTRAR entrar em um canal"
            client.client.puts "COMANDOS mostra os comandos"
            client.client.puts "PS: lembre-se, comandos em maiusculo rsrsrs"
            client.client.puts "PS1: Os comandos precisam estar separados por um espaço do seu argumento"
            client.client.puts
            client.client.puts "OOHHHH notamos que vc chegou agora!!!!!"
            client.client.puts "Para vc começar a conversar com outras pessoas utilize o comando USUARIO"
            client.client.puts 
            puts "#{Time.now.strftime("%H:%M")} #{client.nick} Entrou no canal! "
        end 
    rescue IO::WaitReadable, Errno::EINTR, Errno::EPIPE
    end

    if clientes != []
        clientes.each do |cls|
            system("stty echo")
            mensagem = cls.client.read_nonblock(10000) rescue nil
            system("stty echo")
            
            cl_ms[cls.client] = mensagem
            if mensagem.to_s.tr("\n","") != ""
                puts "#{Time.now.strftime("%H:%M")} #{cls.nick} disse: #{mensagem}"
                flagComando = parser(mensagem,cls,clientes,canais)
                clientes.each do |aux|
                    if !flagComando && aux.canal == cls.canal && aux != cls 
                        aux.client.puts "#{Time.now.strftime("%H:%M")} #{cls.nick}:  #{cl_ms[cls.client].to_s.tr("\n","")}"
                    end
                end
            end   
        end   
    end  

    sleep(1)
 }
 