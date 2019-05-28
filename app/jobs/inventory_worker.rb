require 'httparty'
require 'json'
require 'groups_module'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"


class InventoryWorker < ApplicationJob

	include GroupsModule
	# include AppController
	# include Sidekiq::Worker
	# sidekiq_options retry: false

	queue_as :default

	@@nuestros_productos = ["1004", "1005", "1006", "1009", "1014", "1015"]
	@@id_almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon]
	

	def have_producto(sku, cantidad_minima, inventario_total)
		#inventario_total = getInventoriesCero()

		puts "have_producto(" + sku + ", " + cantidad_minima.to_s + ", " + ")\n"

		for producto in inventario_total
			#puts "Producto sku: " + producto["sku"]
			if producto["sku"].to_s == sku && producto["cantidad"].to_f < cantidad_minima.to_f
				return 0
			elsif producto["sku"].to_s == sku && producto["cantidad"].to_f >= cantidad_minima.to_f
				return 1
			end
		end
		return 2
	end

	def mover_ingrediente_a_despacho(sku, cantidad_ingrediente)
		inventario =  getSkuOnStock()
		puts "getSkuUnStock: \n" + inventario.to_s + "\n"
		stock_en_almacen = Hash.new

		# Partimos almacenes en 0
		id_almacenes = [@@id_despacho, @@id_recepcion, @@id_pulmon, @@id_cocina]
		for almacen in id_almacenes
			stock_en_almacen[almacen] = {"cantidad" => 0}
		end

		# Agregamos los almacenes que tienen stock del producto
		for producto in inventario
			puts "producto[sku]: " + producto["sku"] + "\n"
			if producto["sku"] == sku
				puts "Encontramos el producto en esta bodega"
				almacen = producto["almacenId"]
				cantidad = producto["cantidad"]
				stock_en_almacen[almacen] = producto
				puts "stock_en_almacen[almacen]: " + stock_en_almacen[almacen].to_s + "\n"
			end
		end
		unidades_por_mover = cantidad_ingrediente

		# Para cada almacen, movemos las unidades
		for almacen in id_almacenes
			# Checkeamos si tenemos unidades en DESPACHO
			if almacen == @@id_despacho
				if stock_en_almacen[almacen]["cantidad"]
					if stock_en_almacen[almacen]["cantidad"] >= unidades_por_mover
						return 1
					else 
						unidades_por_mover -= stock_en_almacen[almacen]["cantidad"]
					end
				end
			else
			# Movemos las unidades en RECEPCIÓN, PULMÓN y COCINA a DESPACHO
				if stock_en_almacen[almacen]["cantidad"]
					if stock_en_almacen[almacen]["cantidad"] >= unidades_por_mover
						mover_a_almacen(@@api_key, almacen, @@id_despacho, [sku], unidades_por_mover)
						return 1
					else 
						mover_a_almacen(@@api_key, almacen, @@id_despacho, [sku], 0)
						unidades_por_mover -= stock_en_almacen[almacen]["cantidad"]
					end
				end
			end
		end 
		
		return 1
	end

	def getInventoriesAll # Mismo retorno que getInventories pero incluyendo todos los productos, incluso los con stock 0
		response = []
		skus_quantity = {}
		sku_name = {}
		lista_skus = getSkuOnStock
		productos_all = Producto.all
		for sku in lista_skus
			product_sku = sku["sku"]
			product_name = sku["nombre"]
			quantity = sku["cantidad"]
			if skus_quantity.key?(product_sku)
				skus_quantity[product_sku] += quantity
			else
				sku_name[product_sku] = product_name
				skus_quantity[product_sku] = quantity
			end
		end
		for prod in productos_all
			product_sku = prod.sku
			product_name = prod.nombre
			quantity = 0
			if skus_quantity.key?(product_sku)
				#skus_quantity[product_sku] += quantity
				#sku_name[product_sku] = product_name
			else
				sku_name[product_sku] = product_name
				skus_quantity[product_sku] = quantity
			end
		end
		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		#res = response.to_json
		#render plain: res, :status => 200
		#return response.to_json

		return response

	end

	def getInventoriesOne(sku) # Retorna stock de un solo producto
		inventario_total = getInventoriesAll
		inventario_total.each do |inventario|
			sku_inventario = inventario["sku"]
			if sku == sku_inventario
				return inventario
			end
		end
	end

	def getProductosMinimos
		p_minimos = Producto.where('stock_minimo != ? OR sku = ?', 0, '1101')
		p_minimos.each do |p_referencia|
			if p_referencia.sku == '1101'
				p_referencia.stock_minimo = 300
			end
		end
		return p_minimos
	end

	def pedir_producto_grupos(sku_a_pedir, cantidad_a_pedir)

		puts "\nPEDIR PRODUCTO A GRUPOS\npedir_producto_grupos(" + sku_a_pedir.to_s + ", " + cantidad_a_pedir.to_s + ")\n"

		cantidad_faltante = cantidad_a_pedir

		# Obtenemos el producto en Producto
		producto = Producto.find(sku_a_pedir)

		# Obtenemos sus grupos productores
		grupos_productores = producto.grupos

		# Para cada grupo productor, revisamos su inventario
		grupos_productores.each do |grupo|
			if cantidad_faltante == 0
				return 1
			end
			if grupo.group_id == 4
				next
			end
			puts "Grupo: " + grupo.group_id.to_s + ", URL: " + grupo.url.to_s + "\n"
			inventario_grupo = solicitar_inventario(grupo.group_id)
			inventario_grupo.each do |p_inventario|
				#puts "sku_a_pedir: " + sku_a_pedir + "\n"
				#puts "p_inventario[sku]: " + p_inventario['sku'] + "\n"
				# Si el grupo productor tiene inventario, lo pedimos
				if sku_a_pedir == p_inventario["sku"]
					puts p_inventario.to_s
					cantidad_inventario = p_inventario["total"]
					puts "Inventario: " + cantidad_inventario.to_s + "\n"

					# Si el inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante
					if cantidad_inventario >= cantidad_faltante
						puts "El inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante"
						solicitar_orden(sku_a_pedir, cantidad_faltante, grupo.group_id)
						cantidad_faltante = 0

					# Si el inventario es menor a la cantidad faltante, pedimos todo el inventario
					else
						puts "El inventario es menor a la cantidad faltante, pedimos todo el inventario"
						solicitar_orden(sku_a_pedir, cantidad_inventario, grupo.group_id)
						cantidad_faltante -= cantidad_inventario
					end

				end
			end
		end
		return 0
	end

	
	def perform
		
		puts "\n****************************\nInventory worker checkeando inventario\n****************************\n\n"

		pedidos = Hash.new

		## Obtenemos el inventario total de cada producto ##
		inventario_total = getInventoriesAll()
		puts "Inventario Total: \n" + inventario_total.to_s
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
			if cantidad < stock_minimo # Si la cantidad es mayor o igual al stock minimo, no hago nada

				puts "\nCantidad Actual: " + cantidad.to_s

				# Calculamos la cantidad faltante de producto como la diferencia entre el stock minimo y la cantidad actual en inventario
				cantidad_faltante = stock_minimo - cantidad

				# Obtenemos el tamaño de los lotes de producción del producto
				lote_produccion = p_minimo.lote_produccion

				# Los lotes faltantes a producir seran la cantidad faltante dividida en el lote de producción del producto
				lotes_faltantes = (cantidad_faltante.to_f / lote_produccion.to_f).ceil

				# Calculamos la cantidad a fabricar del producto
				cantidad_a_producir = lotes_faltantes * lote_produccion

				puts "\nCantidad Faltante: " + cantidad_faltante.to_s + " -> Lotes Faltantes: " + lotes_faltantes.to_s
				puts "\n****************************\n\n"
				puts "Ingredientes: \n"

				# Si el producto es MASAGO, lo pido a los grupos productores correspondientes
				if sku.to_i == 1013
					#get_producto_grupo(1013, cantidad_faltante)
					#break #cambio a revisar al siguiente producto de p_minimos

				# Si el producto NO es MASAGO, debo verificar el stock de sus ingredientes antes de fabricar
				else
						
					# Obtenemos los ingredientes del producto
					ingredientes = IngredientesAssociation.where(producto_id: p_minimo.sku)

					# Para cada ingrediente, calculamos el stock necesario para producir el producto y pedimos en caso de no tenerlo
					ingredientes.each do |ingrediente|

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
							puts "\t ¡Tenemos el ingrediente! Enviamos a despacho " + cantidad_ingrediente.to_s + " unidades.\n"

							# Enviamos ingredientes a despacho
							mover_ingrediente_a_despacho(ingrediente.ingrediente_id, cantidad_ingrediente)

							# Fabricamos sin costo los ingredientes enviados
							fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, cantidad_ingrediente)

							###### Enviar ingredientes en tandas de 80 unidades y mandar a producir producto proporcional a 80 unidades de ingrediente

						# Si el stock actual es menor a la cantidad de ingrediente requerido, calculamos la cantidad faltante de ingrediente
						else
							cantidad_faltante_ingrediente = cantidad_ingrediente - p_ingrediente_inventario["cantidad"]

							if @@materias_primas_propias.include? ingrediente.ingrediente_id 

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

							# Si el producto no es nuestro, lo pedimos a otro grupo
							else

								#get_producto_grupo(p_ingrediente.sku, cantidad_faltante_ingrediente)

							end
						end

					end

					#fabricar_sin_pago(@@api_key, p_referencia.sku, lotes_faltantes_p_referencia)
					puts "Fabricamos sin pago el sku " + p_minimo.sku + ", una cantidad de " + cantidad_a_producir.to_s + "\n"
					puts fabricar_sin_pago(@@api_key, p_minimo.sku, cantidad_a_producir)
					puts "\nFabricado"
				end
			end			
		end
	end
	
end