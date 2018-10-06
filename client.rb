require 'socket'      

hostname = 'localhost'
port = 2000
str = ""
socket = TCPSocket.open(hostname, port)

loop{
  loop do
        line = socket.gets
        puts line
        system("stty raw -echo")
        str = STDIN.read_nonblock(10000) rescue nil
        system("stty -raw echo")
        break if str.to_s.include? "\n"
        sleep(5) 
    end
    socket.puts(str)
}
         