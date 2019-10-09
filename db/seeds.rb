# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Language.create(short: 'en', name: 'English')

Warning::DEFAULTS.each { |name| Warning.create(name: name, canonical: true) }
Rating::DEFAULTS.each { |name| Rating.create(name: name, canonical: true) }
Category::DEFAULTS.each { |name| Category.create(name: name, canonical: true) }
