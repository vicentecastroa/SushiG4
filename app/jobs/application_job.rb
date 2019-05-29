require 'job_module'
# require "#{Rails.root}/app/controllers/concerns/job_module"

class ApplicationJob < ActiveJob::Base
	include AppController
end
