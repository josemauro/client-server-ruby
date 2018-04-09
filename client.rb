# Jose Mauro Ribeiro
# Trabalho de Redes de computadores
# 2018.1


require 'socket'
include Socket::Constants


puts "\nStarting ◆ Ruby Client ◆ ... \n\n"

ARGC = ARGV.length #number of arguments   

if ARGC == 0
	print "\n Check the arguments (e.g.: client.rb www.someaddress.com port )\n\n"
	exit
end

if ARGC == 2
	PORT = Integer(ARGV[1])
else
	PORT = 80
end

#hostname = Socket.gethostbyname(ARGV[0].split("/")[0])
hostname = ARGV[0].split("/")[0]

path_of_file = ARGV[0].dup
path_of_file.slice!(hostname)

if path_of_file == ""
	path_of_file = "/" 
	file_name = "index.html"
else 
	file_name = ARGV[0].split("/")
	file_name = file_name[file_name.length - 1]
end


socket = Socket.new(AF_INET, SOCK_STREAM, 0)

sockaddr = Socket.sockaddr_in(PORT, hostname)

socket.connect(sockaddr)
print "Connected to "+hostname+" \n"
mensagem = "GET "+path_of_file+" HTTP/1.0\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)\r\nHost: "+hostname+"\r\n\r\n"

socket.write(mensagem)

results = socket.read

status_code = results.split("\n")[0].split(" ")

if status_code[1] == "200"
	file = open("./saved/"+file_name, 'w')
	write = 0
	#remove request line and header
	results.each_line do |line|
		if line == "\r\n"
			write = 1
		end
		if write == 1
			file.write(line)
		end
	end
else
	i = 0
	while i < status_code.length
		print status_code[i]+" "
		i = i + 1
	end
end
print results
print "\n\n"
socket.close
