require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end

	private
	def init_inventory_worker
		InventoryWorker::perform()
		# SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	end

	def init_test_worker
		MeLlamoWorker::perform()
		# render text: "El worker esta funcionanto"
	end

	def index
		start
		StockAvailableToSell() #no borrar esta funcion debe llamarse entrando al endpoint root/inventories
		# despacho_a_recepcion()
		# mover_a_almacen(@@api_key, @@id_pulmon, @@id_recepcion, 5)
		# puts fabricar_sin_pago(@@api_key, "1105", 40)
		# InventoryWorker::perform()
		#cocinar 
		InventoryWorker::perform()
	end

	def create
	end

	def destroy
	end

	def update
	end

end
