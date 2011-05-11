#!/usr/bin/env ruby

# Scripts for getting projects names and creation dates from Gitorious
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

base_url = "http://gitorious.org"
group_url = "/+emergya-developers"

doc = Nokogiri::HTML(open base_url + group_url)

projects = Hash. new
doc.xpath('//ul/li[@class = "project"]/a').collect do |row|
    name = row.text
    link = row.attribute('href').value
    projects[name] = link
end

projects.each do |project, link|
    puts "Project: #{project} and Link: #{link}"
    project_doc = Nokogiri::HTML(open base_url + link)
    project_doc.xpath('//ul[@id = "project-meta"]/li').each do |row|
        if row.at_css('strong').text == 'Created:'
            date = row.text.delete "Created:"
            puts "Project: #{project}\tCreated: #{date}"
        end
    end
end
