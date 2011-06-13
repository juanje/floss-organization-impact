#!/usr/bin/env ruby

# Script for getting some stats from git repositories
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

root_dir = Dir.pwd

if ARGV.length > 0
    root_dir = ARGV[0] if File.directory?(ARGV[0])
end

projects = []
Dir.foreach(root_dir) do |dir|
    if not dir.start_with?(".")
        projects.push(dir) if File.directory?(root_dir + dir + "/.git")
    end
end

file = File.open("git-dataset.csv", "w")
file.puts "Project,Date,Author"

projects.each do |project|
    dirname = File.join(root_dir, project)
    Dir.chdir dirname
    authors_data = `git log --pretty=format:%aE\\|%aN\\|%aD`.split("\n").uniq
    authors_data.each do |data|
        email, name, date = data.split("|")
        file.puts "#{project},\"#{date}\",\"#{name}\""
    end
end

file.close
