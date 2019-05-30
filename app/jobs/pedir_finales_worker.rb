require 'httparty'
require 'json'
# require 'oc_helper'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"


class PedirFinalesWorker < ApplicationJob


	def solicitar_OC_timeout(sku, cantidad, grupo_id)

		# Primero debemos crear la OC

		cliente = @@IDs_Grupos["4"]
		proveedor = @@IDs_Grupos[grupo_id.to_s] 
		sku = sku.to_s
		fechaEntrega = "1607742000000" #12/12/2020
		cantidad = cantidad.to_s
		precioUnitario = "1"
		canal = "b2b"
		url = "https://tuerca4.ing.puc.cl/documents/{_id}/notification"

		oc_creada = crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)

		# Luego debemos solicitar el producto al grupo, incluyendo el id de la OC

		oc_id = oc_creada["_id"]

		puts "\nSe creo la ordern id: " + oc_creada["_id"] + "\n" 

		# Para solicitar producto a un grupo, debes indicar el sku a pedir, la cantidad a pedir y el id del grupo
		# Ejemplo: solicitar_orden("1001", 10, 13)

		pedido_producto = HTTParty.post("http://tuerca#{grupo_id}.ing.puc.cl/orders",
			body:{
				"sku": sku,
				"cantidad": cantidad,
				"almacenId": @@id_recepcion,
				"oc": oc_id
			}.to_json,
			headers:{
				"group": "4",
				"Content-Type": "application/json"
			},
			timeout: 10)

		if pedido_producto["aceptado"]
			response = true	
		else
			response = false
		end
		puts "Respuesta del grupo: #{response}"
		return response
	end


	def perform
		job_start()
		producto_id = @@productos_finales.sample
		producto_final = Producto.find(producto_id)

		grupos_productores = ("1".."15").to_a
		grupos_productores.shuffle
		oc = false
		
		until oc || grupos_productores.length == 0
			grupo_id = grupos_productores.pop
			puts "Pidiendo #{producto_final.nombre} al grupo #{grupo_id}\n"
			oc = solicitar_OC_timeout(producto_id, 1, grupo_id)
			puts "Grupo #{grupo_id} entrega: #{oc}"
		end
		job_end()
	end

end