namespace :db do
	desc "Fill database with sample data"

	task populate: :environment do
		User.create!(name: "Sidney Sanders",
					 email: "userr@example.com",
					 password: "foobarfoo",
					 password_confirmation: "foobarfoo")

		10.times do |n|
			name = Faker::Name.name
			email = "user-#{n+1}@example.com"
			password = "passwordpassword"
			User.create!(name: name,
						 email: email,
						 password: password,
						 password_confirmation: password)
		end

		User.all.each do |user|
			10.times do |n|
				image = File.open(Dir.glob(File.join(Rails.root, 'sampleimages', '*')).sample)
				description = %w(Lorem ipsum dolor sit amet).sample
				user.pins.create!(image: image,
								  description: description)
			end
		end
	end
end