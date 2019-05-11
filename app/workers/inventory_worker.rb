require 'httparty'
require 'json'

class InventoryWorker < InventoriesController
	include getInventories
	include Sidekiq::Worker
	sidekiq_options retry: false


	def perform
		
		puts "\nInventory worker checkeando inventario\n"

		request = get_inventories_interno()
		p_minimos = Producto.where.not(stock_minimo: 0) # selecciono los que tienen stock minimo
		p_minimos.each do |p_referencia|
			stock_minimo = p_referencia.stock_minimo
			
			request.each do |bodega|
			
				bodega.each do |producto|
			
					if producto["sku"] == p_referencia.sku and producto["cantidad"] < stock_minimo
						if producto["sku"].to_i == 1013
							pedir_producto(1013, 1)
						else
							ingredientes = IngredientesAssociation.where(producto_id: p_referencia.sku)
							ingredientes.each do |ingrediente|

								#buscar ingrediente en bodega
								# si lo encuentra moverlo a despacho( por id ) y mandar a fabricar
								# si no lo encuentra pedirlo

								pedir_producto(ingrediente.sku, 1)
							end
						end
					end
				end
			end
		end
	end
end