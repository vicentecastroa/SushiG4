require 'httparty'
require 'json'

class VaciarPulmonWorker < ApplicationJob

	queue_as :default

	def perform
		job_start()
		perform_pulmon()
		job_end()
	end


end