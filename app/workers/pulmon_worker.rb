require 'json'

class PulmonWorker < ApplicationController

	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform
		puts "\n--------------------------------------\n"
		puts "Iniciando Pulmon Worker\n"
		puts "--------------------------------------\n"

		@items = Producto.all

		for item in @items
			sku = item.sku
			@request = get_products_from_almacenes(@@api_key, @@id_pulmon, sku)
			for prod in @request
				prod_id = prod['_id']
				response = mover_producto_entre_almacenes(prod_id, @@id_recepcion)
				
			end 
		end
	end
end