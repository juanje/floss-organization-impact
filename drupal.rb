#!/usr/bin/env ruby

# Scripts for getting some stats from Drupal
#
# This software is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this package; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Copyright:: Copyright (c) 2011, Emergya
# Authors:: Juanje Ojeda (mailto:jojeda@emergya.es)

require 'open-uri'
require 'nokogiri'

organization = "Emergya"

base_url = "http://drupal.org"
organizations_url = "/profile/profile_current_company_organization/"

org_url = base_url + organizations_url + organization
doc = Nokogiri::HTML(open org_url)

users_links = doc.xpath('//div[@class = "name"]/a').collect do |row|
  link = row.attribute('href').value 
end

def get_issues user
  url = "http://drupal.org/project/issues/user/#{user}/feed"
  doc = Nokogiri::XML(open url)

  issues = doc.xpath('//item').collect do |node|
    {
      :title => node.xpath("./title").text,
      :date  => node.xpath("./pubDate").text
    }
  end
end

def get_projects user
  url = "http://drupal.org/project/user/#{user}/feed"
  doc = Nokogiri::XML(open url)

  #FIXME: get right the XML elements
  issues = doc.xpath('//item').collect do |node|
    {
      :title => node.xpath("./title").text,
      :date  => node.xpath("./pubDate").text
    }
  end
end

users_links.each do |user_link|
  url = base_url + user_link
  doc = Nokogiri::HTML(open url)
  name = doc.xpath('//h1[@id = "page-title"]').text
  projects = doc.xpath('//dl/dd/div[@class = "item-list"]/ul/li[@class != "last"]').count
  commits = doc.xpath('//dl/dd/div[@class = "item-list"]/ul/li[@class = "last"]').text
  commits = commits.split(': ')[1]
  puts "\nName: #{name}\t\tProjects: #{projects}\tNum. Commits: #{commits}"

  url = base_url + user_link + "/track"
  doc = Nokogiri::HTML(open url)
  ["Issue", "Project", "Project release", "Forum topic"].each do |type|
    posts = doc.xpath("//tbody/tr/td[text() = \"#{type}\"]").count
    puts "Posts type #{type}: #{posts}"
  end
end
