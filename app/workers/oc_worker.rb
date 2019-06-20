require 'httparty'
require 'json'

class OcWorker < ApplicationController

	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform_oc
		puts "\nChequeando ordenes de compra generales\n"

		@response = chequeo_ordenes_compra
		@response = JSON.pretty_generate(@response)

		for element in @response do
			@producto = Producto.find('sku')
			if element['sku'] < @producto.stock_minimo
				# Pedir mas de este producto
				# @grupos = @producto.grupos
				# for i in @grupos
				# 	fabricar = fabricar_sin_pago

				if ['Cebollín entero', 'Arroz grano corto', 'Sal', 'Kanikama entero', 'Nori entero'].include? element['sku']
					productos = fabricar_sin_pago(element['sku'], @producto.stock_minimo)
					# Aca no se hace nada mas cierto?
				# else
				# 	# No lo producimos nosotros, pedir a otro grupo

				end
			end
		end
	end
end