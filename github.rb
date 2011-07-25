#!/usr/bin/env ruby

# Scripts for getting some stats from GitHub
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
require 'json'
require 'mash'

BASE_URL = "http://github.com/api/v2/json"
ORGANIZATION = "Emergya"

# Fetches the public_members for a given organization.
def members(org)
  url = BASE_URL + "/organizations/#{ORGANIZATION}/public_members"
  JSON.parse(open(url).read)["users"].collect do |user|
    User.new(user)
  end
end

# Fetches the public_repository for a given organization.
def repositories(org)
  url = BASE_URL + "/organizations/#{ORGANIZATION}/public_repositories"
  JSON.parse(open(url).read)["repositories"].collect do |repo|
    Repository.new(repo)
  end
end

class User < Mash
end

class Repository < Mash
end

puts "#{ORGANIZATION}'s Users:"
members('Emergya').each do |user|
    puts "User: #{user.login}\n\tRepos: #{user.public_repo_count}"
end

puts "\n\n#{ORGANIZATION}'s repositories"
repositories('Emergya').each do |repo|
    puts "Repo: #{repo.name}\n\tDescription: #{repo.description}"
end

