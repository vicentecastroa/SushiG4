require 'net/ftp'

# Require Helpers
require 'application_helper'
require 'variables_helper'


require 'active_support/core_ext/hash'
require 'date'

class ApplicationController < ActionController::Base
	
	include ApplicationHelper
	include ApiOcHelper
	include VariablesHelper
	include ApiBodegaHelper
	include GruposHelper

end

