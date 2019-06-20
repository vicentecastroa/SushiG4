require 'httparty'
require 'json'
require 'net/ftp'
require 'date'
require 'active_support/core_ext/hash'

class ReviewWorker < ApplicationJob
	
	include PerformHelper
	
	queue_as :default

	def perform
		job_start()
		perform_review()
		job_end()

	end
end
