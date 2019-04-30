require 'httparty'
require 'hmac-sha1'
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
			end
		end
	end
end