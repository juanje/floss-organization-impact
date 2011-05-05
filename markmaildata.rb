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

file = File.open("dataset.csv", "w")

dataset = Hash.new
searches = []
urls.each do |name, search_url|
    searches.push name
    search = searches.index name
    url = base_url + search_url
    doc = Nokogiri::HTML(open url)
    serie = Hash.new
    puts "Serie: #{name}"
    doc.xpath('//tr/td[@align = "right"]').collect do |row|
        serie[row.previous_element.text] = row.text
    end
    serie.each do |list, count|
        if dataset.has_key? list
            dataset[list][search] = count
        else
            dataset[list] = ["0", "0", "0"]
            dataset[list][search] = count
        end
    end
    dataset.each_key do |list|
        dataset[list][search] = "0" if not serie.has_key? list
    end
end


file.puts "Lists," + searches.join(",")
dataset.each do |list, counts|
    file.puts list + "," + counts.join(",")
end
file.close

