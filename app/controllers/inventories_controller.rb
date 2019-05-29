require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end
	
	def total_products
		response = getInventories()
		render plain: response
	end

	def sku_stock
		response = getSkuOnStock()
		render plain: response
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
		StockAvailableToSell() #no borrar esta funcion debe llamarse entrando al endpoint root/inventories
	end

	def create
	end

	def destroy
	end

	def update
	end

end
