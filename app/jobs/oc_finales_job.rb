require 'httparty'
require 'json'
# require 'oc_helper'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"


class OcFinales < ApplicationJob

	queue_as :default

	def perform
		job_start()
		producto_id = @@productos_finales.sample
		producto_final = Producto.find(producto_id)
		grupos_productores = producto_final.grupos

		lista_de_grupos = []
		grupos_productores.each do |g|
			lista_de_grupos << g
		end
		grupo_a_pedir = lista_de_grupos.sample
		grupo_id = grupo_a_pedir.group_id
		oc = solicitar_OC(producto_id, 1, grupo_id)
		puts "Grupo #{grupo_id} entrega: #{oc}"
		job_end()
	end


end