require 'bundler/setup'
Bundler.require

page = Wikipedia.find('Getting Things Done')

puts page
puts page.title
puts page.content
puts page.raw_data
