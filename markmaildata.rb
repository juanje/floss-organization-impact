#!/usr/bin/env ruby

# Scripts for getting data from MaikMail search in CSV format
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

base_url = "http://markmail.org/browse/?q="
if File.file? ARGV[0]
    filename = ARGV[0]
else
    puts "ERROR: A file path must be passed as argument"
    exit
end

urls = Hash.new
File.foreach(filename) do |line|
    name, search_url = line.split(";")
    urls[name] = search_url
end

urls.each do |name, search_url|
    url = base_url + search_url
    file = File.open(name + ".txt", "w")
    doc = Nokogiri::HTML(open url)
    doc.xpath('//tr/td[@align = "right"]').collect do |row|
        file.puts "\"#{row.previous_element.text}\", \"#{row.text}\""
    end
    file.close
end

