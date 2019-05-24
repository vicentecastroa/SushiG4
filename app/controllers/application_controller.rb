require 'net/ftp'
require 'ftp_helper'
require 'application_helper'
require 'active_support/core_ext/hash'

class ApplicationController < ActionController::Base
	include ApplicationHelper
	include FtpHelper
	include OcHelper
	
	#protect_from_forgery with: :exception

	@@api_key = 'o5bQnMbk@:BxrE'
	@@id_recepcion = '5cc7b139a823b10004d8e6df'
	@@id_despacho = '5cc7b139a823b10004d8e6e0'
	@@id_pulmon = '5cc7b139a823b10004d8e6e3'
	@@id_cocina = '5cc7b139a823b10004d8e6e4'

	@@id_desarrollo = '5cbd31b7c445af0004739be6'
	@@id_desarrollo_14 = '5cbd31b7c445af0004739bf0'
	@@id_produccion = '5cc66e378820160004a4c3bf'
	
	#desarrollo es true y produccion es false
	@@status_of_work = false

	CONTENT_SERVER_DOMAIN_NAME = 'fierro.ing.puc.cl'
	CONTENT_SERVER_FTP_LOGIN = 'grupo4'
	CONTENT_SERVER_FTP_PASSWORD = 'p6FByxRf5QYbrDC80'
	CONTENT_SERVER_FTP_PORT = 22

	def start
		#revisar_oc
		#orden_creada = crear_oc(@@id_desarrollo, @@id_desarrollo_14, "30001", 1568039052000, "10", "10", "b2b", "https://tuerca4.ing.puc.cl/document/{_id}/notification")
		nueva_oc
		#orden_creada = crear_oc(@@id_desarrollo, @@id_desarrollo_14, "30001", 1558039052000, "10", "10", "b2b")
		#obtener_oc(orden_creada['_id'])
		#aceptar_oc('1557965482159')
		#rechazar_oc(orden_creada["_id"], "RECHAZADO POR X RAZON")
		#anular_oc(orden_creada["_id"], "MUCHOS PRODUCTOS")
		#verificar_conexion(CONTENT_SERVER_DOMAIN_NAME, CONTENT_SERVER_FTP_LOGIN, CONTENT_SERVER_FTP_PASSWORD, CONTENT_SERVER_FTP_PORT)
	end

	def getSkuOnStock
		response = []
		id_almacenes = [@@id_cocina, @@id_pulmon, @@id_recepcion, @@id_despacho]

		for almacen in id_almacenes
			@request = (obtener_skus_con_stock(@@api_key, almacen)).to_a
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
		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		res = response.to_json
		render plain: res, :status => 200
		return response.to_json
	end

	def revisar_oc
		counter = 0
		@host = "fierro.ing.puc.cl"
		@user = "grupo4_dev"
		@password = "1ccWcVkAmJyrOfA"
		Net::SFTP.start(@host, @user, :password => @password) do |sftp|
			sftp.dir.foreach("/pedidos") do |entry|
				break if counter == 10
				counter +=1
				if counter > 2
					data_xml = sftp.download!("pedidos/#{entry.name}")
  					data_json = Hash.from_xml(data_xml).to_json
  					data_json = JSON.parse data_json
  					order_id = data_json["order"]['id']
  					orden_compra = obtener_oc(order_id)
  				end
			end
		end
	end

	def nueva_oc
		orden_creada = crear_oc(@@id_desarrollo, @@id_desarrollo_14, "30001", 1568039052000, "10", "10", "b2b", "https://tuerca4.ing.puc.cl/document/{_id}/notification")
		order_id = orden_creada['_id']
		puts order_id
		Document.create! do |document|
			document.all = order_id,
			document.cliente = orden_creada['cliente'],
			document.proveedor = orden_creada['proveedor'],
			document.sku = orden_creada['sku'],
			document.fechaEntrega = orden_creada['fechaEntrega'],
			document.cantidad = orden_creada['cantidad'],
			document.cantidadDespachada = orden_creada['cantidadDespachada'],
			document.precioUnitario = orden_creada['precioUnitario'],
			document.canal = orden_creada['canal'],
			document.estado = orden_creada['estado'],
			document.notas = orden_creada['notas'],
			document.rechazo = orden_creada['rechazo'], 
			document.anulacion = orden_creada['anulacion'],
			document.order_id = order_id,
			document.urlNotificacion = orden_creada['urlNotificacion']
		end
		anular_oc(orden_creada["_id"], "MUCHOS PRODUCTOS")
	end

end

