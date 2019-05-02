require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end

	def index
		show_inventory

	end

	def create
	end

	def destroy
	end

	def update
	end

	def show_inventory
		@request = (obtener_skus_con_stock(@@api_key, "5cc7b139a823b10004d8e6e0")).to_a
		response = []
		for element in @request do
			sku = element["_id"]
			@product = Producto.find(sku)
			product_name = @product.nombre
			quantity = element["total"]
			line = {"sku" => sku, "nombre" => product_name, "cantidad" => quantity}
			response << line
		end
		res = response.to_json
		render plain: res, :status => 200
		#return response.to_json
	end

end

