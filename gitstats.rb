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
years = %w{2009 2010 2011}

if ARGV.length > 0
    root_dir = ARGV[0] if File.directory?(ARGV[0])
end

projects = []
Dir.foreach(root_dir) do |dir|
    if not dir.start_with?(".")
        projects.push(dir) if File.directory?(root_dir + dir + "/.git")
    end
end

projects.each do |project|
    dirname = File.join(root_dir, project)
    Dir.chdir dirname
    filename = File.join(root_dir, project + ".csv")
    file = File.open(filename, "w")
    file.puts "Year,Author,Commits"
    authors = `git log --pretty=format:%aN`.split("\n").uniq
    years.each do |year|
        authors.each do |author|
            commits = `git log --oneline --author="#{author}" \
                       --since="#{year}-01-01" --until="#{year}-12-31"`
            commits = commits.split("\n").count
            file.puts "#{year},\"#{author}\",#{commits}"
        end
    end
    file.close
end
