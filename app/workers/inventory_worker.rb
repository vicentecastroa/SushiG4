require 'httparty'
require 'json'

class InventoryWorker < InventoriesController
	include getInventories
	include Sidekiq::Worker
	sidekiq_options retry: false

	def check_producers(producto)

		n_grupos = producto.grupos.length
		indices = (0...n_grupos).to_a
		indices.shuffle()
		sku = producto.sku
		
		for i in indices
			request = pedir(producto.grupos[i])
			if request == true
				break
			end
		end
	end

	def mandar_a_cocinar(lista_ingredientes, producto_final)
	end


	def perform
		
		puts "\nInventory worker checkeando inventario\n"

		request = get_inventories()

		minimos = Producto.where.not(stock_minimo: 0)
		minimos.each do |p_referencia|
			stock_minimo = p_referencia.stock_minimo

			pedido = Hash.new

			request.each do |producto|

				if producto["sku"] == p_referencia.sku and producto["cantidad"] < stock_minimo
					ingredientes = IngredientesAssociation.where(producto_id: p_referencia.sku)
					
					for ingrediente in ingredientes
						request.each do |i|

							pedir_producto(i.sku, 1)
						end
					end


					#ver si estan los ingredientes para mandar a cocinar o pedir lo ingredientes.
					next
					
				else 
					puts 'masago'
				end
					
					a_pedir = stock_minimo.to_i - producto["cantidad"].to_i
					pedir(p_referencia.sku, a_pedir)
				end
			end
		end
	end
end