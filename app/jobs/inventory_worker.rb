require 'httparty'
require 'json'
# require 'groups_module'
# require 'oc_helper'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"


class InventoryWorker < ApplicationJob

	# include GroupsModule
	# include OcHelper
	# include AppController

	queue_as :default

	def perform
		
		puts "\n****************************\nInventory worker checkeando inventario\n****************************\n\n"

		pedidos = Hash.new

		## Obtenemos el inventario total de cada producto ##
		inventario_total = getInventoriesAll()
		# puts "Inventario Total: \n" + inventario_total.to_s
		# [{"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}, {}, {}]
		puts "Corrio getInventories"

		p_all = Producto.all

		## Obtenemos los productos que deban mantener un stock minimo ##
		p_minimos = getProductosMinimos()
		# puts "Productos Minimos: \n" + p_minimos.to_s

		## Para cada producto que deba mantener stock minimo, revisamos su stock ##
		p_minimos.each do |p_minimo|

			## Obtenemos el stock minimo que debe mantener el producto ##
			stock_minimo = p_minimo.stock_minimo.to_i

			puts "\n****************************\nProducto Minimo: " + p_minimo.nombre + "\n"
			puts"\nStock Minimo: " + stock_minimo.to_s

			## Obtenemos el producto dentro del inventario ##
			p_minimo_inventario = getInventoriesOne(p_minimo.sku)

			## Por cada producto que deba mantener stock minimo, comparo y encuentro el producto en el inventario
			sku = p_minimo_inventario["sku"]
			cantidad = p_minimo_inventario["cantidad"].to_i

			puts "\nCantidad Actual: " + cantidad.to_s

			if cantidad < stock_minimo # Si la cantidad es mayor o igual al stock minimo, no hago nada


				# Calculamos la cantidad faltante de producto como la diferencia entre el stock minimo y la cantidad actual en inventario
				cantidad_faltante = stock_minimo - cantidad

				# Obtenemos el tamaño de los lotes de producción del producto
				lote_produccion = p_minimo.lote_produccion

				# Los lotes faltantes a producir seran la cantidad faltante dividida en el lote de producción del producto
				lotes_faltantes = (cantidad_faltante.to_f / lote_produccion.to_f).ceil

				# Calculamos la cantidad a fabricar del producto
				cantidad_a_producir = lotes_faltantes * lote_produccion
				total_produccion = cantidad_a_producir
				puts "\nCantidad Faltante: " + cantidad_faltante.to_s + " -> Lotes Faltantes: " + lotes_faltantes.to_s
				puts "\n****************************\n\n"
				puts "Ingredientes: \n"

				# Si el producto es MASAGO, lo pido a los grupos productores correspondientes
				if sku.to_i == 1013
					while cantidad_a_producir > 0 do
						orden = [cantidad_a_producir, 10].min
						nos_entregan = pedir_producto_grupos("1013", orden)
						puts "Nos entregan #{nos_entregan} unidades"
						cantidad_a_producir -= nos_entregan
						puts "Hemos producido #{total_produccion-cantidad_a_producir} de #{total_produccion}\n"
						if nos_entregan == 0
							puts "\nNINGUN grupo tienen mas MASAGO\n"
							break
						end
					end
				# Si el producto NO es MASAGO, debo verificar el stock de sus ingredientes antes de fabricar
				else
						
					# Obtenemos los ingredientes del producto
					ingredientes = IngredientesAssociation.where(producto_id: p_minimo.sku)

					numero_ingredientes = ingredientes.length
					lista_ingredientes = []
					# Para cada ingrediente, calculamos el stock necesario para producir el producto y pedimos en caso de no tenerlo

					contador_ingredientes = 0
					ingredientes.each do |ingrediente|
						
						lista_ingredientes << [ingrediente.ingrediente_id, ingrediente.unidades_bodega.to_i]
						
						puts "\t ID Ingrediente: " + ingrediente.ingrediente_id + "\n"
						
						# Obtenemos el ingrediente desde Producto
						p_ingrediente = Producto.find(ingrediente.ingrediente_id)
						
						# Obtenemos el inventario del ingrediente
						p_ingrediente_inventario = getInventoriesOne(p_ingrediente.sku)
						
						# Obtenemos la cantidad de ingrediente requerido para producir un lote de producto
						unidades_bodega = ingrediente.unidades_bodega

						# Calculamos la cantidad de unidades requeridas multiplicando las unidades bodega por los lotes faltantes de producto
						cantidad_ingrediente = unidades_bodega * lotes_faltantes

						# Si el stock actual es mayor o igual a la cantidad de ingrediente requerido, enviamos ingrediente a despacho y reponemos la misma cantidad
							

						if p_ingrediente_inventario["cantidad"] >= cantidad_ingrediente
							puts "\t ¡Tenemos UN ingrediente! \n"
							
							contador_ingredientes += 1
							puts "contadores: #{contador_ingredientes} / #{numero_ingredientes}\n"
							if contador_ingredientes == numero_ingredientes
								puts "\t ¡Tenemos TODOS LOS ingredienteS! \n"
								puts "Comenzamos la produccion de #{cantidad_a_producir} productos"

								while cantidad_a_producir > 0 do
									# Enviamos ingredientes a despacho

									lista_ingredientes.each do |item|
										mover_ingrediente_a_despacho(item[0], item[1])
									end
									# Fabricamos sin costo los ingredientes enviados
									puts fabricar_sin_pago(@@api_key, p_minimo.sku, lote_produccion)
									cantidad_a_producir -= lote_produccion
									cantidad_a_producir = [cantidad_a_producir, 0].max
									puts "Hemos producido #{total_produccion-cantidad_a_producir} de #{total_produccion}\n"


									# fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, cantidad_ingrediente)
								end

							end
							###### Enviar ingredientes en tandas de 80 unidades y mandar a producir producto proporcional a 80 unidades de ingrediente

						# Si el stock actual es menor a la cantidad de ingrediente requerido, calculamos la cantidad faltante de ingrediente
						else
							puts "No tenemos el ingrediente! \n"
							cantidad_faltante_ingrediente = cantidad_ingrediente - p_ingrediente_inventario["cantidad"]

							if @@materias_primas_propias.include? ingrediente.ingrediente_id 
								puts "El ingrediente es nuestro\n"
								# Obtenemos el tamaño de lote de producción del ingrediente
								lote_produccion_ingrediente = p_ingrediente.lote_produccion

								# Calculamos los lotes faltantes de ingrediente
								lotes_faltantes_ingrediente = (cantidad_faltante_ingrediente / lote_produccion_ingrediente).ceil

								# Definimos factor de multiplicacion de stock minimo para ingredientes propios
								factor_ingredientes = 2

								# Calculamos la cantidad a producir del ingrediente
								cantidad_a_producir_ingrediente = factor_ingredientes * lotes_faltantes_ingrediente * lote_produccion_ingrediente

								# Fabricamos sin costo la cantidad a producir del ingrediente
								puts fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, (cantidad_a_producir_ingrediente).ceil)
								puts "Fabricamos sin pago el ingrediente: " + p_minimo.sku + ", una cantidad de " + cantidad_a_producir.to_s + "\n"

							# Si el producto no es nuestro, lo pedimos a otro grupo
							else
								puts "El ingrediente NO es nuestro\n"
								while cantidad_faltante_ingrediente > 0
									orden = [cantidad_faltante_ingrediente, 10].min
									nos_entregan = pedir_producto_grupos(ingrediente.ingrediente_id, orden)
									puts "Nos entregan #{nos_entregan} unidades"
									cantidad_faltante_ingrediente -= nos_entregan
									
									if nos_entregan == 0
										puts "\nNINGUN grupo tienen mas Producto X\n"
										break
									end
								end
							end
						end
					end
				end
			end			
		end
		job_end()
	end
end
