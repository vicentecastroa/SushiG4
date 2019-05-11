require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end

	def init_check_inventory
		SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	end

	def index
		getInventories
		
		#fabricar_sin_pago(@@api_key, "1004", "100")
		#fabricar_sin_pago(@@api_key, "1005", "100")
		#fabricar_sin_pago(@@api_key, "1014", "100")
		
		#get_almacenes(@@api_key)
		#get_products_from_almacenes_limit_primeros(@@api_key, "5cbd3ce444f67600049431c6", "1001", "3")
		#mover_producto_entre_bodegas(@@api_key, "5cc359f04f65bf0004136cd0", "5cbd3ce444f6760004943201", "hola", "50")
		#mover_producto_entre_almacenes("5cc359f04f65bf0004136ccf", "5cbd3ce444f67600049431c5")
		#obtener_skus_con_stock(@@api_key, "5cbd3ce444f67600049431c5")
		
		# api_key = "o5bQnMbk@:BxrE"
		# @almacenes = get_almacenes(@@api_key)
		# @products = get_products_from_almacenes(@@api_key, "5cbd3ce444f67600049431c7", "1001")
		# @fabricados = fabricar_sin_pago(@@api_key, "1001", "20")
		# @skus = obtener_skus_con_stock(@@api_key, "5cbd3ce444f67600049431c7")

	end

	def create
	end

	def destroy
	end

	def update
	end

	def getInventories
		response = []
		skus_quantity = {}
		sku_name = {}
		id_almacenes = [@@id_cocina, @@id_pulmon, @@id_recepcion, @@id_despacho]

		for almacen in id_almacenes
	
			@request = (obtener_skus_con_stock(@@api_key, almacen)).to_a
			for element in @request do
				sku = element["_id"]
				@product = Producto.find(sku)
				product_name = @product.nombre
				quantity = element["total"]
				if skus_quantity.key?(sku)
					skus_quantity[sku] += quantity
				else
					sku_name[sku] = product_name
					skus_quantity[sku] = quantity
				end
			end
		end 

		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		res = response.to_json
		render plain: res, :status => 200
		return response.to_json
	end

end
