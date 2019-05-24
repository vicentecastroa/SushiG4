require 'app_controller_module'
require "#{Rails.root}/app/controllers/concerns/app_controller_module"

class ApplicationJob < ActiveJob::Base
	include AppController
end
