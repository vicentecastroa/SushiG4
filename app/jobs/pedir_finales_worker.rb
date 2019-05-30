require 'httparty'
require 'json'
require 'timeout'
# require 'oc_helper'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"


class PedirFinalesWorker < ApplicationJob

	def perform
		job_start()
		producto_id = @@productos_finales.sample
		producto_final = Producto.find(producto_id)

		grupos_productores = (1..14).to_a
		oc = false

		lista_negra = [4]
		
		lista_negra.each do |l|
			grupos_productores.delete(l)
		end
		
		grupos_productores = grupos_productores.shuffle
		
		until oc || grupos_productores.length == 0
			grupo_id = grupos_productores.pop
			puts "Pidiendo #{producto_final.nombre} al grupo #{grupo_id}\n"
			oc = solicitar_OC(producto_id, 1, grupo_id)
			puts "Grupo #{grupo_id} entrega: #{oc}"
		end
		job_end()
	end

end