require 'socket'      

hostname = 'localhost'
port = 2000

server = TCPSocket.open(hostname, port)

server.puts("auishfuiashfuifsa")

loop{
    puts "saiu"
    loop do
        line = server.gets
        puts line
        system("stty raw -echo")
        char = STDIN.read_nonblock(1) rescue nil
        system("stty -raw echo")
        break if /q/i =~ char
        sleep(1)
    end
}
         