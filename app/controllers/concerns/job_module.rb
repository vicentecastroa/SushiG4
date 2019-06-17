module JobModule
	include ApplicationHelper
	include ApiOcHelper
	include VariablesHelper
	include ApiBodegaHelper
	include GruposHelper
	include PerformHelper
	include ReviewHelper


	def job_start
		puts "\n**********************************************"
		puts "\n******** INICIO DE #{self.class} ********"
		puts "\n**********************************************\n\n"
	end
	
	def job_end
		puts "\n**********************************************"
		puts "\n******* FIN DE #{self.class} *********"
		puts "\n**********************************************\n\n"
	end


end

