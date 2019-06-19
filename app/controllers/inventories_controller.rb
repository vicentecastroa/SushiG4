require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	include PerformHelper

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

	def init_check_inventory
		perform_inventory()
		render plain: 'funcion inventory'
		# InventoryWorker::perform()
		# SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	end

	def init_review
		perform_review()
		render plain: 'funcion review'
	end

	def init_delivery
		perform_delivery()
		render plain: 'funcion delivery'
	end

	def init_test_worker
		MeLlamoWorker::perform()
		# render text: "El worker esta funcionanto"
	end

	def pedir_todo
		pedir_todo_materias_primas()
		#pedir_producto_grupo('1', '1010', 1)
		render plain: 'funcion pedir todo'
	end

	def index
		StockAvailableToSell()
	end

	def create
	end

	def destroy
	end

	def update
	end

end
