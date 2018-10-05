require 'socket'      

hostname = 'localhost'
port = 2000

server = TCPSocket.open(hostname, port)

server.puts("auishfuiashfuifsa")
loop{
    line = server.gets
    puts line
    server.puts("oi")
    server.puts("oi")
    server.puts("oi")
    server.puts("sfa")
    server.puts("sfg")
    server.puts("ogsag")

}
    


         