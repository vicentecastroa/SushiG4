class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@api_key = "o5bQnMbk@:BxrE"

  	# Funcion que hay que editar
	def hashing(data, api_key)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
  end
  
end
