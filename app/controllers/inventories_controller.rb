require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end

	def index
		show_inventory
		
		#fabricar_sin_pago(@@api_key, "1004", "100")
		#fabricar_sin_pago(@@api_key, "1005", "100")
		#fabricar_sin_pago(@@api_key, "1014", "100")
		
		#get_almacenes(@@api_key)
		#get_products_from_almacenes_limit_primeros(@@api_key, "5cbd3ce444f67600049431c6", "1001", "3")
		#mover_producto_entre_bodegas(@@api_key, "5cc359f04f65bf0004136cd0", "5cbd3ce444f6760004943201", "hola", "50")
		#mover_producto_entre_almacenes("5cc359f04f65bf0004136ccf", "5cbd3ce444f67600049431c5")
		#obtener_skus_con_stock(@@api_key, "5cbd3ce444f67600049431c5")
		
	end

	def create
	end

	def destroy
	end

	def update
	end

	def show_inventory
		@request = (obtener_skus_con_stock(@@api_key, "5cbd3ce444f67600049431c6")).to_a
		response = []
		for element in @request do
			sku = element["_id"]
			@product = Producto.find(sku)
			product_name = @product.nombre
			quantity = element["total"]
			line = {"sku" => sku, "nombre" => product_name, "cantidad" => quantity}
			response << line
		end
		res = response.to_json
		render plain: res, :status => 200
		#return response.to_json
	end

end

