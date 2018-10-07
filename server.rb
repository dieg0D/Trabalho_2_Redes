require 'socket' #biblioteca de sockets do ruby                

server = TCPServer.open(2000) #abre a conexão tcp na porta 2000
clientes = [] #array que será usado para guardar os clientes conectados
cl_ms = {}   #hash onde ficará guardados o cliente e a mensagem que ele mandou pra ser replicado pros outros clientes
client = "" #varaivel que receb o cliente que sera inserido no vetor
mensagem = "" #variavel que receb as mensagens
canais = ["General", "Séries", "Músicas", "Jogos", "Filmes"] #array com os possiveis canais do servidor

class Client #classe que estrutura um cliente
    
    attr_accessor :client, :nick, :canal, :usuario  #cria os metodos getters e setters
    @@count_users = 0 #contador que é usado pra diferenciar os clientes no nick inicial
    def initialize(client) #metodo construtor 
        @client = client # variavel de instancia que receb o cliente que foi conectado no servidor na essencia recebe o socket
        @nick = "User#{@@count_users}" #coloca um nick arbitrário quando o cleinte entra no servidor
        @canal = 0 #canal fake onde o lciente não pode se comunicar com outros em suma é como se ele tivesse fora de qualquer canal
        @usuario = "" #nome do usuario está vazio pois assim que entra o cliente é obrigado a color seu usuario pra poder se comunicar
        @@count_users = @@count_users+1 # incrementa o contador
    end

    def listar(clientes, canais) #metodo que lista os canais e quantas pessoas então em cada canal
        
        @client.puts 
        canais.each_with_index do |cn, index|
            @client.puts "Canal {#{index+1}} - #{cn} #{contar(clientes, index+1)} pessoas conectadas " #retorna pro cliente o canal e quantas pessoas tem nele
        end
        @client.puts 
    end
    
    private

        def contar(clientes, num) #conta quantas pessoas tem em cada canal 
            count=0
            clientes.each do |usr|
                if usr.canal == num
                    count=count+1
                end
            end
            count
        end
end

def parser(msg,client,clientes,canais) #esse metodo recebe a mensagem escrita pelo cliente e verifica se ela possui um comando se possuir ela executa tal comando
    ivet = msg.to_s.split(' ',2) #da split no primeiro espaço pra checar se é um comando ou não
    comando = ivet[0] 
    aux = ivet[1]
    flag =false #flag que indica se é um comando pois caso seja esse mensagem não deve ser replicada pra outros clientes

    if client.usuario == "" && comando != "USUARIO" && comando != "SAIR" # checa se o cliente já informou o seu usario pois se não ele deve fazer isso pra depois se comunicar
        comando = "ERROR"
    end    

    if client.usuario != "" && client.canal == 0 && comando != "SAIR" && comando != "LISTAR" &&   # checa se o usuario tá fora de um canal
                                                    comando != "ENTRAR" && comando != "NICK" && 
                                                    comando != "USUARIO" && comando != "COMANDOS"  
        
        comando = "ERROR2"
    end    

    case comando #switch case ...
    when "NICK"  #troca o nick do usuario caso ele seja unico se não for manda uma mensagem explicando o ocorrido
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
    when "USUARIO" #troca o nome de usuario do cliente
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
    when "LISTAR" # lista todos os canais disponiveis e quantas pessoas tem nele
        client.listar(clientes,canais)

        client.client.puts 
        client.client.puts "Utilize o comando ENTRAR com o numero do canal para poder ir para ele"
        client.client.puts 
        flag=true 
    when "SAIR" #sai do servidor ou seja fecha a conexão se apos isso o cliente tentar se comuncar o progama do cliente será encerrado
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
    when "SAIRC" #sai do canal atual 
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
    when "ENTRAR" #entra em um canal caso já esteja em um você é trocado
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
    when "COMANDOS" #mostra os comando disponiveis no chat
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
    when "ERROR" # manda um mensagem de erro para que o cliente informe seu usuario

        client.client.puts 
        client.client.puts "Para vc começar a conversar com outras pessoas utilize o comando USUARIO"
        client.client.puts 
        flag=true
    when "ERROR2" #manda mensagem de erro se o cleinte tentar se comunicar estando fora de um canal
        client.client.puts         
        client.client.puts "Você não está conectado"
        client.client.puts "utilize o comando LISTAR para ver os canais disponiveis"
        client.client.puts "E utilize o comando ENTRAR para entrar no canal desejado"
        client.client.puts 
        flag=true 
    else
             
    end
    flag #retorna o a flag citada anteriormente 
end    

puts "Server iniciado!"
loop { #loop infinito do servidor para sair do progama de um CTRL + C porem não dê CTRL + C do codigo do cliente pq se não vc tá fazendo errado ...
    begin
        client = Client.new(server.accept_nonblock) #aceita a conexão do socket do cliente
        unless clientes.include?(client) # se é a primeira requicisão do cleinte mostra essa bela msg de boas vindas =D
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
    rescue IO::WaitReadable, Errno::EINTR, Errno::EPIPE # trata essas essas exceções ae 
    end

    if clientes != []  #checa se tem clientes no servido
        clientes.each do |cls| #percorre o vetor de servidoes pra ver se tem msg 
            system("stty echo")
            mensagem = cls.client.read_nonblock(10000) rescue nil # recebe mensagem do cliente aki está sendo usado chamadas do sistem e um read não blocante apra que o servidor não fique travado durante o recebimento de mensagem
            system("stty echo")
            
            cl_ms[cls.client] = mensagem #poem msg e cliente na hash 
            if mensagem.to_s.tr("\n","") != "" 
                puts "#{Time.now.strftime("%H:%M")} canal#{cls.canal} #{cls.nick}: #{mensagem}" #printa mesngem recebida no server
                flagComando = parser(mensagem,cls,clientes,canais) # chama o parser 
                clientes.each do |aux|  #replica a mensagem pros outros clientes no canal 
                    if !flagComando && aux.canal == cls.canal && aux != cls # checa se não é ele mesmo e se os clientes estão no mesmo canal
                        aux.client.puts "#{Time.now.strftime("%H:%M")} #{cls.nick}:  #{cl_ms[cls.client].to_s.tr("\n","")}" #manda mensagem pra cliente
                        aux.client.puts
                    end
                end
            end   
        end   
    end  

    sleep(1) #sleep pro server poder receber as mensagens sem "bugar"
 }

