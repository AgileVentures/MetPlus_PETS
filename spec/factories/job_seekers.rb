FactoryGirl.define do
	factory :job_seeker do
		year_of_birth "1998"
		resume nil
		status :unemployed_seeking
		association :address, factory: :address
		user
	end
end
