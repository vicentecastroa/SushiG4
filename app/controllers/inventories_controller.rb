require 'httparty'
require 'hmac-sha1'
require 'json'

module InventoriesHelper

	# Funcion que hay que editar
	def hashing(data, api_key)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
	end

	def get_almacenes(api_key)
		data = "GET"
		hash_value = hashing(data, api_key)
		almacenes = HTTParty.get('https://integracion-2019-dev.herokuapp.com/bodega/almacenes', 
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		puts "\nALMACENES\n"
		puts JSON.pretty_generate(almacenes)
		return almacenes
	end

	def get_products_from_almacenes(api_key, almacenId, sku)
		data = "GET#{almacenId}#{sku}"
		hash_value = hashing(data, api_key)
		products = HTTParty.get("https://integracion-2019-dev.herokuapp.com/bodega/stock?almacenId=#{almacenId}&sku=#{sku}",
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		puts "\nPRODUCTOS DE ALMACENES\n"
		puts JSON.pretty_generate(products)
		return products
	end

	def obtener_skus_con_stock(api_key, almacenId)
		data = "GET#{almacenId}"
		hash_value = hashing(data, api_key)
		skus = HTTParty.get("https://integracion-2019-dev.herokuapp.com/bodega/skusWithStock?almacenId=#{almacenId}",
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		puts "\nSKUS\n"
		puts JSON.pretty_generate(skus)
		return skus
	end

	def fabricar_sin_pago(api_key, sku, cantidad)
		data = "PUT#{sku}#{cantidad}"
		hash_value = hashing(data, api_key)
		products_produced = HTTParty.put("https://integracion-2019-dev.herokuapp.com/bodega/fabrica/fabricarSinPago",
		  body:{
		  	"sku": sku,
		  	"cantidad": cantidad
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })

		puts "\nFABRICAR SIN PAGO\n"
		puts JSON.pretty_generate(products_produced)
		return products_produced
	end
end


class InventoriesController < ApplicationController
	include InventoriesHelper

	def show
	end

	def index
		# api_key = "o5bQnMbk@:BxrE"
		@almacenes = get_almacenes(@@api_key)
		@products = get_products_from_almacenes(@@api_key, "5cbd3ce444f67600049431c7", "1001")
		@fabricados = fabricar_sin_pago(@@api_key, "1001", "20")
		@skus = obtener_skus_con_stock(@@api_key, "5cbd3ce444f67600049431c7")

	end

	def create
	end

	def destroy
	end

	def update
	end

	def show_inventory
		@request = obtener_skus_con_stock(@@api_key, "5cbd3ce444f67600049431c7")
		response = []
		for element in @request do
			sku = element["_id"][sku]
			@product = Producto.find(sku)
			name= @product.nombre
			quantity = element["total"]
			
			line = {"sku" => sku, "nombre" => name, "cantidad" => quantity}
			response << line
			
		end
		puts "\nFUNCIONA\n"
		return response.to_json
	end		

end
# end

