require 'socket'      

hostname = 'localhost'
port = 2000

server = TCPSocket.open(hostname, port)


while line = server.gets    
   puts line.chop       
end

         