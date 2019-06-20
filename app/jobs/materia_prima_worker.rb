require 'httparty'
require 'json'
# require 'groups_module'
# require 'oc_helper'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"

class MateriaPrimaWorker < ApplicationJob

	queue_as :default

	def perform
		job_start()
		pedir_todo_materias_primas()
		job_end()
	end


end