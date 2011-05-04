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
search_url = "from:emergya%20-type:checkins%20date:2010"
url = base_url + search_url

doc = Nokogiri::HTML(open url)
doc.xpath('//tr/td[@align = "right"]').collect do |row|
  puts "\"#{row.previous_element.text}\", \"#{row.text}\""
end

