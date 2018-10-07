require 'socket'    

hostname = 'localhost'
port = 2000
str = ""
socket = TCPSocket.open(hostname, port)

loop{
  loop do
        system("stty echo")
        mensagem = socket.read_nonblock(10000) rescue nil
        system("stty echo")
        if mensagem.to_s.tr("\n","") != ""
            puts mensagem
        end    
        system("stty echo")
        str = STDIN.read_nonblock(10000) rescue nil
        system("stty echo")
        break if str.to_s.include? "\n"
    end
    begin
        socket.puts(str)  
    rescue => Errno::EPIPE
        socket.close
        exit!
    end 
}
         