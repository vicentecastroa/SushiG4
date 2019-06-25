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

	def arrocero_init
		perform_arroz()
		render plain: 'funcion arrocero'
	end

	def init_check_inventory
		perform_inventory()
		render plain: 'funcion inventory'

		# InventoryWorker::perform()
		# SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	end

	def init_vaciar_pulmon
		perform_pulmon()
		render plain: 'funcion vaciar_pulmon'
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
		#solicitar_OC("1007", 20, 13)
		render plain: 'funcion pedir todo'
	end

	def vaciar_despacho
		despacho_a_recepcion()
		render plain: 'funcion vaciar despacho'

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

	def allstock
		@stock, @cantidad_almacenes, @capacidad_almacenes = getPrintStock()
	end

	def cocina
		@cocina = getCocinaStock()
	end

end
