require 'httparty'
require 'json'

class DespacharWorker < ApplicationJob

	queue_as :default

	def perform
		job_start()
		perform_delivery()
		job_end()
	end


end