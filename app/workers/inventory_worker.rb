require 'httparty'
require 'json'

class InventoryWorker < ApplicationController

	include Sidekiq::Worker
	sidekiq_options retry: false

	def check_producers(producto)

		n_grupos = producto.grupos.length
		indices = (0...n_grupos).to_a
		indices.shuffle()
		sku = producto.sku
		# ingredientes = IngredientesAssociation.where(producto_id=sku)
		
		for i in indices
			request = pedir(producto.grupos[i])
			if request == true
				break
			end
		end
	end


	def perform
		puts "\nInventory worker checkeando inventario\n"


		stock_pulmon = obtener_skus_con_stock(@@api_key, @@id_pulmon)
		stock_recepcion = obtener_skus_con_stock(@@api_key, @@id_recepcion)
		stock_despacho = obtener_skus_con_stock(@@api_key, @@id_despacho)
		stock_cocina = obtener_skus_con_stock(@@api_key, @@id_cocina)

		# entregan [{}, {_id: xx , cantaidad }, ...]


		minimos = Producto.where.not(stock_minimo: 0)
		productos_a_pedir = []

		minimos.each do |p_referencia|
			stock_minimo = p_referencia.stock_minimo
			productos_a_pedir << {p_referencia.sku => 0}

			request = get_inventories()

			request.each do |producto|
				if producto["sku"] == p_referencia.sku and producto["cantidad"] < stock_minimo
					a_pedir = stock_minimo.to_i - producto["cantidad"].to_i
					pedir(p_referencia.sku, a_pedir)
				end
			end


			stock_pulmon.each do |p_pulmon|

			end

			stock_recepcion.each do |p_recepcion|
				if 
			end

			stock_despacho.each do |p_despacho|
				if 
			end

			stock_cocina.each do |p_cocina|
				if 
			end

		end
		
	end
end