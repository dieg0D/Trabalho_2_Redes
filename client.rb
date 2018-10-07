require 'socket' #biblioteca de sockets do ruby

hostname = 'localhost' #hostname vai ser o do local host pois está seno rodado tudo local
port = 2000 #porta onde vai ser feita a conexão
str = "" #vai receber as entradas do teclado
socket = TCPSocket.open(hostname, port) #aloca o socket que vai se conectar com o server

loop{ #loop infinito do cliente 
  loop do
        system("stty echo")
        mensagem = socket.read_nonblock(10000) rescue nil # recebe mensagem do servidor aki está sendo usado chamadas do sistem e um read não blocante apra que o cleinte não fique travado durante o recebimento de mensagem
        system("stty echo")
        if mensagem.to_s.tr("\n","") != "" # se a mensagme do servidor não for algo vazio como um nil 
            puts mensagem    #printa no cliente a mensagem do servidor
        end    
        system("stty echo")
        str = STDIN.read_nonblock(10000) rescue nil rescue nil # recebe a entrada do teclado isso é usado pois o cliente tem qeu estar apto a receber e enviar mesnagens simultaneamente e não podemos usar thread então essa é uma solução
        system("stty echo")
        break if str.to_s.include? "\n" # se a tecla ENTER for precionada sai do loop interno
    end
    begin
        socket.puts(str)  # envia pro servidor a mensagem
    rescue => Errno::EPIPE #trata essas tretas ae
        socket.close # fecha o cliente quando o comano exit for usado 
        exit! #sai do progama =P
    end 
}
         