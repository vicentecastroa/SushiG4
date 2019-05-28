module FtpHelper

	def status_of_work_function(status)
		# 	if status
		# 	  CONTENT_SERVER_DOMAIN_NAME = "fierro.ing.puc.cl"
		# 	  CONTENT_SERVER_FTP_LOGIN = "grupo4_dev"
		# 	  CONTENT_SERVER_FTP_PASSWORD = "1ccWcVkAmJyrOfA"

		# 	else
		# 	  CONTENT_SERVER_DOMAIN_NAME = "fierro.ing.puc.cl"
		# 	  CONTENT_SERVER_FTP_LOGIN = "grupo4"
		# 	  CONTENT_SERVER_FTP_PASSWORD = "p6FByxRf5QYbrDC80"
		# 	end
	end

	def conexion
		@host = "fierro.ing.puc.cl"
		@user = "grupo4"
		@password = "p6FByxRf5QYbrDC80"
		Net::SFTP.start(@host, @user, :password => @password) do |sftp|
			# upload a file or directory to the remote host
			#sftp.upload!("/path/to/local", "/path/to/remote")
		  
			# download a file or directory from the remote host
			#sftp.download!("/path/to/remote", "/path/to/local")
		  
			# grab data off the remote host directly to a buffer
			#data = sftp.download!("/path/to/remote")
		  
			# open and write to a pseudo-IO for a remote file
			#sftp.file.open("/path/to/remote", "w") do |f|
			#  f.puts "Hello, world!\n"
			#end
		  
			# open and read from a pseudo-IO for a remote file
			#sftp.file.open("/path/to/remote", "r") do |f|
			#  puts f.gets
			#end
		  
			# list the entries in a directory
			sftp.dir.foreach("/") do |entry|
				puts 'ARCHIVO 1'
				puts entry.longname
			end
		end
	end
end