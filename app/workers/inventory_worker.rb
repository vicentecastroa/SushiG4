require 'httparty'
require 'json'

class InventoryWorker < ApplicationController

	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform
		puts "\nInventory worker checkeando inventario\n"

		@response = obtener_skus_con_stock(@@api_key, @@id_despacho)
		@response = JSON.pretty_generate(@response)

		for element in @response do
			@producto = Producto.find('sku')
			if element['sku'] < @producto.stock_minimo
				# Pedir mas de este producto
				# @grupos = @producto.grupos
				# for i in @grupos
				# 	fabricar = fabricar_sin_pago

				if ['Cebollín entero', 'Arroz grano corto', 'Sal', 'Kanikama entero', 'Nori entero'].include? element['sku']
					productos = fabricar_sin_pago(@@api_key, element['sku'], @producto.stock_minimo)
					# Aca no se hace nada mas cierto?
				# else
				# 	# No lo producimos nosotros, pedir a otro grupo

				end
			end
		end
	end
end