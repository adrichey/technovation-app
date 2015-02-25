# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# user = User.new(
#   first_name: 'Cory',
#   last_name: 'Li',
#   email: 'finalepsilon@gmail.com',
#   parent_email: 'finalepsilon@gmail.com',
#   password: 'testtest',
#   role: 0,
#   password_confirmation: 'testtest',
#   birthday: Date.new(1989, 12, 1),
#   home_city: 'Raleigh',
#   home_state: 'NC',
#   home_country: 'US',
#   school: 'MIT',
# )
# user.skip_confirmation!
# user.save!


# user = User.new(
#   first_name: 'Cassandra',
#   last_name: 'Xia',
#   email: 'cssndrx+judge@gmail.com',
#   password: 'testtest',
#   role: 3,
#   password_confirmation: 'testtest',
#   birthday: Date.new(1989, 12, 1),
#   home_city: 'Boston',
#   home_state: 'MA',
#   home_country: 'US',
#   school: 'MIT',
# )
# user.skip_confirmation!
# user.save!


setting = Setting.create(
  key: 'year',
  value: '2015',
)

setting = Setting.create(
  key:'cutoff',
  value: Date.today.to_s,
)

setting = Setting.create(
  key:'judgeSignupOpen',
  value: Date.today.to_s,
)

setting = Setting.create(
  key:'submissionOpen',
  value: Date.today.to_s,
)

setting = Setting.create(
  key:'judgeSignupClose',
  value: Date.today.to_s,
)

setting = Setting.create(
  key:'submissionClose',
  value: Date.today.to_s,
)

# 04/24/2015 - judging round 1 opens quarterfinalJudgingOpen
# 05/03/2015 - judging round 1 closes quarterfInalJudgingClose
# 05/05/2015 - judging round 2 opens semifinalJudgingOpen
# 05/10/2015 - judging round 2 closes semifinalJudgingClose
# quarterfinalScoresVisible
# semifinalScoresVisible

event = Event.create(
  name: 'Virtual Judging',
  location: 'Online',
  whentooccur: DateTime.new(2015, 07, 11, 20, 10, 0),
  description: 'Quarterfinals for everyone',
)

event = Event.create(
  name: 'Northeast Quarterfinals',
  location: 'MIT',
  whentooccur: DateTime.new(2015, 07, 11, 20, 10, 0),
  description: 'Quarterfinals for the Northeast',
)

event = Event.create(
  name: 'Bay Area Quarterfinals',
  location: 'Dropbox',
  whentooccur: DateTime.new(2015, 07, 11, 20, 10, 0),
  description: 'Quarterfinals for the Bay Area',
)

category = Category.create(
  name: 'Health and fitness',
  year: '2015',
)

category = Category.create(
  name: 'Envrionment',
  year: '2015',
)

category = Category.create(
  name: 'Community values',
  year: '2015',
)


# setting = Setting.create(
#   key: 'submissionOpen?',
#   value: true,
# )

# setting = Setting.create(
#   key: 'submissionDeadline',
#   value: Date.today.to_s,
# )

ann = Announcement.create(
  title: "Welcome to Technovation's new site",
  post: "For the 2015 season, we're using a brand new website to organize, submit, and publish your projects. If you have any questions, please email us at info@technovationchallenge.org!",
  published: true,
)
