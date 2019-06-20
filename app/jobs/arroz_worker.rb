require 'httparty'
require 'json'

class HacerArrozWorker < ApplicationJob

	queue_as :default

	def perform
		job_start()
		perform_arroz()
		job_end()
	end


end