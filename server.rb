require 'socket'
require 'filemagic'
include Socket::Constants

port = ARGV[1]

sockaddr = Socket.sockaddr_in(Integer(port), "127.0.0.1")

socket = Socket.new(AF_INET, SOCK_STREAM, 0)

socket.setsockopt(:SOCKET, :REUSEADDR, true)

socket.bind(sockaddr)

socket.listen(8)
	
path_of_file = "/" # path_of_file define the path to requested file

loop do
	Thread.fork(socket.accept) do |client| 
		request = client[0].recvfrom(1024)[0] # get the packet HTTP
		request = request.split("\n")[0].chomp # get the request from header
		
		root = ARGV[0]
						
		path_of_file = request.split[1]
		if path_of_file == "/"		
			path_of_file = root
		else 
			path_of_file = root+ path_of_file[1..path_of_file.length]
		end
	
		
		
		file_name = ""
		
		#check if file or directory exist	
		if path_of_file != root
			if File.exists?(path_of_file) != true
				client[0].puts("HTTP/1.1 200\r\nContent-Type: text/html\r\n\r\n
							<div id=\"main\"> <div class=\"fof\">
							<h1>Error 404</h1></div></div>")
				client[0].close
			end
		end
		
		#if the path is a directory
		if path_of_file == root or File.directory?(path_of_file) or path_of_file == "../"
			
			# define the link for previous directory (pd) on HTML page
			if path_of_file == root
				pd = "/"
			else
				pd = path_of_file.split("/")
				pd.pop()
				new_pd = ""
				if pd.any?()
					for i in pd
						new_pd += i+"/"
					end
					pd = new_pd.sub('./', "/")
				else
					pd = "/"
				end
			end			
		
			folder = path_of_file
			
			#allows the client request a folder writing or not a "/" on the end of the path
			if folder[folder.length-1] != "/"
				folder = folder+"/"
			end
			
			folder = folder + "*"
			
			files = Dir[folder]

			answer = "HTTP/1.1 200\r\nContent-Type: text/html\r\n\r\n<header><title>Files on directory</title></header> <body> <ul>"
			if path_of_file != root
				answer += "<li> <a href="+ pd +"> ../</a></li>"
			end
			for item_path in files
				item = item_path.split("/")
				item = item[item.length - 1]
				answer = answer + "<li> <a href=" +item_path.sub('./', "/")+">" + item + "</a></li>"
			end
			answer = answer + "</ul></body> </html>"
			client[0].puts(answer)
			client[0].close
		#check if file or directory exists
		else	
			f = open(path_of_file, "r")
			client[0].puts("HTTP/1.1 200\r\nContent-Type: "+FileMagic.new(FileMagic::MAGIC_MIME).file(path_of_file)+"\r\n\r\n"+f.read)
			f.close
			client[0].close
		end
	end
end
