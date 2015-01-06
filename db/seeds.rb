# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

SpecScope.find_or_create_by(scope: "GSM only (< Rel-4)")
SpecScope.find_or_create_by(scope: "GSM only (>= Rel-4)")
SpecScope.find_or_create_by(scope: "3G and beyond / GSM (R99 and later)")
