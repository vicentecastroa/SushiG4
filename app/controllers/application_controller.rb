class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@api_key = "o5bQnMbk@:BxrE"

  	# Funcion que hay que editar
	def hashing(data, api_key)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
  	end

  	def mover_producto_entre_bodegas(api_key, productoId, almacenId, oc, precio)
		data = "POST#{productoId}#{almacenId}"
		hash_value = hashing(data, api_key)
		producto_movido = HTTParty.post('https://integracion-2019-dev.herokuapp.com/bodega/moveStockBodega',
		  body:{
		  	"productoId": productoId,
		  	"almacenId": almacenId,
		  	"oc": "null",
		  	"precio": 0,
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		puts "\nMOVER PRODUCTO ENTRE BODEGAS\n"
		puts JSON.pretty_generate(producto_movido)
		return producto_movido
	end
  
end
