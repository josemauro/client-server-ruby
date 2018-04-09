require 'socket'
include Socket::Constants

port = ARGV[1]
folder = ARGV[0]+"*"

files = Dir[folder]

#socket = Socket.new(AF_INET, SOCK_STREAM, 0)

#sockaddr = Socket.sockaddr_in(Integer(port), 'localhost')

#socket.bind(sockaddr)

#socket.listen(5)

socket = TCPServer.new(Integer(port))  

loop do
	Thread.fork(socket.accept) do |client| 
		request = client.gets
		path_of_file = request.split[1]		
		
		file = ""
		
		if path_of_file != "/"
			file = path_of_file.split("/")
			file = file[file.length-1]
			#check if file or directory exists
			if File.exists?(file) != true
				client.puts("HTTP/1.1 200\r\nContent-Type: text/html\r\n\r\n <div id=\"main\">    	<div class=\"fof\">        		<h1>Error 404</h1>    	</div></div>")
				client.close
			end
		end
		
		if path_of_file == "/" 
			answer = "HTTP/1.1 200\r\nContent-Type: text/html\r\n\r\n<header><title>Files on directory</title></header> <body> <ul>"
			for item in files
				answer = answer + "<li> <a href=" +item+">" + item + "</a></li>"
			end
			answer = answer + "</ul></body> </html>"
			client.puts(answer)
			client.close
		else
			f = open(file, "r")
			client.puts("HTTP/1.1 200\r\nContent-Type: text/html\r\n\r\n"+f.read)
			f.close
			client.close
		end
	end
end
