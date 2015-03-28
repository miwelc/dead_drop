namespace :dead_drop do

	desc "Remove expired entries"
	task clean_up: :environment do
		DeadDrop.cache.cleanup
	end

end
