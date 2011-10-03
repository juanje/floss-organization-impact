#!/usr/bin/env ruby

load File.dirname(__FILE__) + '/lib/model.rb'

author = "Emergya"
years = [2009, 2010, 2011]

include Model

hostname = 'localhost'
database = 'datasets'
Mongoid.database = Mongo::Connection.new(hostname).db(database)

commits = Model::Commit

repos = years.inject({}) do |result,year|
  result[year] = commits.where(:author => author).
                         and(:commited_at.gt => Time.parse("#{year}-01-01")).
                         and(:commited_at.lt => Time.parse("#{year+1}-01-01")).
                         all.collect {|c| c.repo }.uniq
  result
end

repos.each_pair do |year,values|
  puts "#{year}: #{values.join(', ')}"
end

