require 'socket'
include Socket::Constants

server = Socket.new(AF_INET, SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(2000, 'localhost')
server.connect(sockaddr)


loop{
    puts "saiu"
    loop do
        puts server.readline.chomp
        system("stty raw -echo")
        char = STDIN.read_nonblock(1) rescue nil
        system("stty -raw echo")
        break if /q/i =~ char
        sleep(1)
    end
}
         