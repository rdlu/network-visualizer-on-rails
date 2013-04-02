# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :nameserver do
	address "8.8.8.8"
	name "google"
	internal false
	primary true
	vip false
  end
end
