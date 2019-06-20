require 'httparty'
require 'json'
# require 'groups_module'
# require 'oc_helper'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"


class InventoryWorker < ApplicationJob

	include PerformHelper

	# include GroupsModule
	# include OcHelper
	# include AppController

	def perform

		job_start()
		perform_inventory()
		job_end()

	end



end
