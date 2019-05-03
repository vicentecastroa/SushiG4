require 'json'

class RecepcionWorker < ApplicationController
	# Mueve de Recepcion a despacho
	
	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform
		puts "\n--------------------------------------\n"
		puts "Iniciando Recepcion Worker\n"
		puts "--------------------------------------\n"

		@items = Producto.all

		for item in @items
			sku = item.sku
			@request = get_products_from_almacenes(@@api_key, @@id_recepcion, sku)
			for prod in @request
				prod_id = prod['_id']
				response = mover_producto_entre_almacenes(prod_id, @@id_despacho)
				
			end 
		end
	end
end
