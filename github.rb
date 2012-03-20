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
require 'date'

class Organization < Mash
  BASE_URL = "http://github.com/api/v2/json"
  attr_reader :name

  def initialize(org)
    if org.class == String
      @name = org
      url = BASE_URL + "/organizations/#{@name}"
      org_hash = JSON.parse(open(url).read)["organization"]
      Organization.new(org_hash)
    else
      @name = org["name"]
    end
  end

  # Fetches the public_members for a given organization.
  def members
    url = BASE_URL + "/organizations/#{@name}/public_members"
    begin
      opened_url = open(url)
    rescue
      []
    else
      JSON.parse(open(url).read)["users"].collect do |user|
        User.new(user)
      end
    end
  end

  # Fetches the public_repository for a given organization.
  def repositories
    url = BASE_URL + "/organizations/#{@name}/public_repositories"
    JSON.parse(open(url).read)["repositories"].collect do |repo|
      Repository.new(repo)
    end
  end

  # Fetches the commits for a given repository.
  def self.commits(user,repository,branch="master")
    url = BASE_URL + "/commits/list/#{user}/#{repository}/#{branch}"
    begin
      opened_url = open(url)
    rescue
      Hash.new Commit.new(:user => user,
                          :repository => repository,
                          :id => 0,
                          :authored_date => "0000-01-01")
    else
      JSON.parse(opened_url.read)["commits"].collect{ |c|
        Commit.new(c.merge(:user => user, :repository => repository))
      }
    end
  end

  def self.user_repositories(user)
    # Fetches the repositories for a given user.
    url = BASE_URL + "/repos/show/#{user}"
    begin
      opened_url = open(url)
    rescue
      []
    else
      JSON.parse(open(url).read)["repositories"].collect{ |r|
        Repository.new(r.merge(:user => user))
      }
    end
  end

  def commits_per_year(year)
    total_commits = 0
    members.each_with_index do |member,index|
      user = member.login
      next if (repositories = Organization.user_repositories(user)).empty?
      # This is a dirty hack to avoid get Github API satured
      sleep 10 if index.modulo(4) == 0
      own_commits = 0
      org_commits = 0
      puts "\nUser: #{user}"
      repositories.each do |repository|
        next unless repository
        repo = repository.name
        num_commits = Organization.commits(user, repo).collect { |commit|
          commit_year = Date.parse(commit.authored_date).strftime("%Y").to_i
          commit.id if commit_year == year
        }.compact.count
        if repository.owner == @name
          puts "\t#{@name}'s repo: #{repo}\tNum. Commits: #{num_commits}"
          org_commits += num_commits
        else
          puts "\tOwn repo: #{repo}\tNum. Commits: #{num_commits}"
          own_commits += num_commits
        end
      end
      puts "\n\tTotal commits on #{user}'s repos: #{own_commits}\n"
      puts "\tTotal commits on #{@name}'s repos: #{org_commits}\n"
      total_commits = total_commits + own_commits + org_commits
    end
    puts "\n\nTotal commits from #{@name} users:\t#{total_commits}"
  end
end

class User < Mash
end

class Repository < Mash
end

class Commit < Mash
  def detailed
    url = BASE_URL + "/commits/show/#{@user}/#{@repository}/#{id}"
    commit = JSON.parse(open(url).read)["commit"]
    Commit.new(commit.merge(:user => @user, :repository => @repository))
  end

end

if ARGV.length > 0
  organization = ARGV[0]
else
  puts "ERROR: You need to pass a Organization name as a parameter"
  exit
end

org = Organization.new(organization)

puts "#{org.name}'s Users:"
org.members.each do |user|
  puts "User: #{user.login}\tRepos: #{user.public_repo_count}"
end

puts "\n\n#{org.name}'s repositories"
org.repositories.each do |repo|
  puts "Repo: #{repo.name}\n\tDescription: #{repo.description}"
end

puts "\n\nCommits from #{org.name}'s members at 2011"
org.commits_per_year(2011)
