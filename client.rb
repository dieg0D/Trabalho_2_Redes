require 'socket'      

hostname = 'localhost'
port = 2000

server = TCPSocket.open(hostname, port)
msg = " "
while msg != '\x18'
    line = " "
    line = server.gets
    t = Time.now
    if line != " "
        puts line.chomp
    end    
     puts "digite sua msg: "
     server.puts "ksfldjsaklfs"
end
    


         