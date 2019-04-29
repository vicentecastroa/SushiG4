require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end

	def index
		get_almacenes(@@api_key)
		get_products_from_almacenes_limit_primeros(@@api_key, "5cbd3ce444f67600049431c6", "1001", "3")
		#mover_producto_entre_bodegas(@@api_key, "5cc359f04f65bf0004136cd0", "5cbd3ce444f6760004943201", "hola", "50")
		#mover_producto_entre_almacenes("5cc359f04f65bf0004136ccf", "5cbd3ce444f67600049431c5")
		obtener_skus_con_stock(@@api_key, "5cbd3ce444f67600049431c5")
		#fabricar_sin_pago(@@api_key, "1001", "10")
		
	end

	def create
	end

	def destroy
	end

	def update
	end

end

