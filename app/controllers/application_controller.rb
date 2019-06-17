require 'net/ftp'



require 'active_support/core_ext/hash'
require 'date'

class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	
	include ApplicationHelper

end

