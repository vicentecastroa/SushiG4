class SchedulerWorker
	include Sidekiq::Worker
	sidekiq_options queue: 'critical'
  
	SCHEDULE = {
	  InventoryWorker  => -> (time) { time.min == 5 },
	#   SecondWorker => -> (time) { time.min == 0 && time.hour == 9 },
	#   ThirdWorker  => -> (time) { time.min % 10 == 0 },
	}
  
	def perform
		execution_time = Time.zone.now
		execution_time -= execution_time.sec
  
		self.class.perform_at(execution_time + 60) unless scheduled?

		SCHEDULE.each do |(worker_class, schedule_lambda)|
		worker_class.perform_async if !scheduled?(worker_class) && schedule_lambda.call(execution_time)
		end
	end
  
	def scheduled?(worker_class = self.class)
	  scheduled_workers[worker_class.name]
	end
  
	private
	def scheduled_workers
		@scheduled_workers ||= Sidekiq::ScheduledSet.new.entries.each_with_object({}) do |item, hash|
		hash[item['class']] = true
		end
	end
end