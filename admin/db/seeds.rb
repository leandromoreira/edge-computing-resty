# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

ch = Channel.create!(label: "test", segment_duration_ms: 5 * 1000)

all_programs = "a".."g"
all_renditions = ["216p600kbs", "432p1000kbs", "720p878kbs"]
sixty = 60*1000
thirty = 30*1000
all_durations = {
  "a" => thirty,
  "b" => thirty,
  "c" => thirty,
  "d" => thirty,
  "e" => thirty,
  "f" => thirty,
  "g" => sixty,
}

video = nil
all_programs.each do |program|
  video = Video.new label: "program #{program}", duration_ms: all_durations[program]
  all_renditions.each do |rendition|
    video.renditions << Rendition.new(label: "#{program} - #{rendition}", path: "/program_#{program}_720p.mp4_#{rendition}.mp4")
  end
  video.save!
  Schedule.create! channel: ch, video: video # one schedule per program
end

(0..20).each do |x|
  Schedule.create! channel: ch, video: video # last program 1m
end
