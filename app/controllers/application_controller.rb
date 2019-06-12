require 'net/ftp'

# Require Helpers
require 'application_helper'
require 'variables_helper'


require 'active_support/core_ext/hash'
require 'date'

class ApplicationController < ActionController::Base
	
	include ApplicationHelper
	include ApiOcHelper
	include VariablesHelper
	include ApiBodegaHelper
	include GruposHelper

	def start
		# Funcion que llama a /inventories
		# revisar_oc
	end

	def solicitar_inventario(grupo_id)

		# Para ver e inventario de un grupo, debes indicar el id del grupo
		# Ejemplo: solicitar_inventario(13)

		inventario_grupo = HTTParty.get("http://tuerca#{grupo_id}.ing.puc.cl/inventories")
		if @@print_valores
			puts "\nInventario de Grupo " + grupo_id.to_s + ": \n" + inventario_grupo.to_s + "\n"
		end
		return inventario_grupo
	end

	def recepcion_a_cocina
		# Vaciamos Pulmón
		mover_a_almacen(@@id_pulmon, @@id_cocina, @@materias_primas_propias, 5)
		# Vaciamos Recepción
		mover_a_almacen(@@id_recepcion, @@id_cocina, @@materias_primas_propias, 5)
	end

	def cocina_a_recepcion
		# Vaciamos Cocina
		vaciar_almacen(@@id_cocina, @@id_recepcion, @@materias_primas_propias)
	end

	def despacho_a_recepcion
		# D Cocina
		mover_a_almacen(@@id_despacho, @@id_recepcion, @@materias_primas_propias, 200)
		mover_a_almacen(@@id_despacho, @@id_pulmon, @@materias_primas_propias, 200)
	end

	def getSkuOnStock
		response = []
		id_almacenes = [@@id_cocina, @@id_pulmon, @@id_recepcion, @@id_despacho]

		for almacen in id_almacenes
			@request = (obtener_skus_con_stock(almacen)).to_a
			for element in @request do
				sku = element["_id"]
				@product = Producto.find(sku)
				product_name = @product.nombre
				quantity = element["total"]
				line = {"almacenId" => almacen, "sku" => sku, "cantidad" => quantity, "nombre" => product_name}
				response << line
			end
		end 

		return response
	end

	def getInventories
		response = []
		skus_quantity = {}
		sku_name = {}
		lista_skus = getSkuOnStock
		puts "get inventories 1"
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
		puts "get inventories 2"

		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		res = response.to_json
		# render plain: res, :status => 200
		return response.to_json
	end

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
		puts "getSkuOnStock: \n" + inventario.to_s + "\n"
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
						mover_a_almacen(almacen, @@id_despacho, [sku], unidades_por_mover)
						return 1
					else 
						mover_a_almacen(almacen, @@id_despacho, [sku], 0)
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

	def pedir_producto_grupos(sku_a_pedir, cantidad_a_pedir)

		puts "\nPEDIR PRODUCTO A GRUPOS\n"
		cantidad_faltante = cantidad_a_pedir
		# Obtenemos el producto en Producto
		producto = Producto.find(sku_a_pedir)
		# Obtenemos sus grupos productores
		grupos_productores = producto.grupos

		
		lista_de_grupos = []
		grupos_productores.each do |g|
			lista_de_grupos << g
		end
		
		# REVIEW blacklist black list lista negra
		lista_negra = [4] # 8, 10, 12
		
		lista_negra.each do |l|
			lista_de_grupos.each do |gr|
				if gr.group_id == l
					lista_de_grupos.delete(gr)
				end
			end
		end
		
		lista_de_grupos = lista_de_grupos.shuffle

		# Para cada grupo productor, revisamos su inventario
		cantidad_entregada = 0

		lista_de_grupos.each do |grupo|
			if cantidad_faltante == 0
				return 1
			end
			# if grupo.group_id == 4 || grupo.group_id == 12 || grupo.group_id == 14 || grupo.group_id == 10 || #grupo.group_id == 5
			# 	next
			# end

			puts "Revisando grupo: " + grupo.group_id.to_s + ", URL: " + grupo.url.to_s + "\n"
			inventario_grupo = solicitar_inventario(grupo.group_id)
			
			if inventario_grupo
				inventario_grupo.each do |p_inventario|
					#puts "sku_a_pedir: " + sku_a_pedir + "\n"
					#puts "p_inventario[sku]: " + p_inventario['sku'] + "\n"
					# Si el grupo productor tiene inventario, lo pedimos
					if sku_a_pedir == p_inventario["sku"]
						puts p_inventario.to_s
						cantidad_inventario = p_inventario["total"]

						# Si el inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante
						if cantidad_inventario >= cantidad_faltante
							puts "El inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante"
							# solicitar_orden_OC(sku_a_pedir, cantidad_faltante.to_i, grupo.group_id)
							if solicitar_OC(sku_a_pedir, cantidad_faltante.to_i, grupo.group_id)
								return cantidad_faltante
							else
								next
							end
							# cantidad_faltante = 0

						# Si el inventario del otro grupo es menor a la cantidad faltante, pedimos todo el inventario
						else
							puts "El inventario es menor a la cantidad faltante, pedimos todo el inventario"
							if solicitar_OC(sku_a_pedir, cantidad_inventario.to_i, grupo.group_id)
								# solicitar_orden_OC(sku_a_pedir, cantidad_inventario.to_i, grupo.group_id)
								cantidad_faltante -= cantidad_inventario
								cantidad_entregada += cantidad_inventario
							end
						end
					end
				end
				# return cantidad_faltante
			end
		end
		return cantidad_entregada
	end

end

