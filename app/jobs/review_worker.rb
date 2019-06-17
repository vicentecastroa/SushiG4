require 'httparty'
require 'json'
require 'net/ftp'
require 'date'
require 'active_support/core_ext/hash'

class ReviewWorker < ApplicationJob
	
	include PerformHelper
	
	queue_as :default

	
	# def cocinar(sku_a_cocinar, cantidad_a_cocinar)

	# 	puts "\nCOCINAR\n"
	# 	puts "SKU a cocinar: #{sku_a_cocinar}, Cantidad: #{cantidad_a_cocinar}\n"

	# 	ingredientes = IngredientesAssociation.where(producto_id: sku_a_cocinar)

	# 	numero_ingredientes = ingredientes.length
	# 	lista_ingredientes = []

	# 	puts "Este producto necesita #{numero_ingredientes} ingredientes\n"

	# 	contador_ingredientes = 0

	# 	puts "Checkeamos disponibilidad de ingredientes\n"
	# 	puts ingredientes
	# 	ingredientes.each do |ingrediente|
	# 		puts ingrediente
	# 		cantidad_ingrediente = getInventoriesOne(ingrediente.ingrediente_id)
	# 		cantidad_necesaria = cantidad_a_cocinar * ingrediente.unidades_bodega
	# 		puts "Necesitamos #{cantidad_necesaria} unidades del sku #{ingrediente.ingrediente_id}. Tenemos #{cantidad_ingrediente["cantidad"]} unidades\n"
	# 		if cantidad_ingrediente["cantidad"]  < cantidad_necesaria
	# 			puts "Ingrediente no disponible"
	# 			return false
	# 		end
	# 		puts "Ingrediente disponible"
	# 	end

	# 	ingredientes.each do |ingrediente|
			
	# 		a_mover = cantidad_a_cocinar * ingrediente.unidades_bodega
	# 		puts "Moviendo #{a_mover} unidades del sku #{ingrediente.ingrediente_id} a la Cocina\n"
	# 		movidos = 0
	# 		almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon, @@id_despacho]
			
	# 		almacenes.each do |almacen|
	# 			if a_mover > 0
	# 				movidos = mover_a_almacen(@@api_key, almacen, @@id_cocina, [ingrediente.ingrediente_id], a_mover)
	# 				a_mover = a_mover - movidos
	# 				if movidos > 0
	# 					puts "Movimos #{movidos} unidades del sku #{ingrediente.ingrediente_id} a la Cocina. Faltan #{a_mover} por mover\n"
	# 				end
	# 			end
	# 		end

	# 	end
	# 	response = fabricar_sin_pago(@@api_key, sku_a_cocinar, cantidad_a_cocinar)

	# 	respuesta = response["disponible"]
	# 	if respuesta
	# 		puts response
	# 		return response["disponible"]
	# 	end
	# 	return nil

	# end

	# def revisar_cocina
	# 	puts "--------- ENTRO A REVISAR_COCINA --------"
	# 	@documents = Document.all
	# 	@documents.each do |document|
	# 		sku = document["sku"]
	# 		cantidad = document["cantidad"]
	# 		order_id = document["order_id"]

	# 		# review                    
	# 		values = obtener_skus_con_stock(@@id_cocina)
	# 		values.each do |value|
	# 			if value["_id"].to_s == sku.to_s
	# 				if value["total"] >= cantidad 
	# 					despacho_todos(@@id_cocina, sku, cantidad, order_id)
	# 					document.destroy
	# 				end
	# 			end
	# 		end
	# 	end
	# end


	def perform
		# job_start()
		# revisar_oc()
		# revisar_cocina()
		# # revisar_cocina_worker()
		# job_end()

		job_start()
		perform_review()
		job_end()

	end
end
