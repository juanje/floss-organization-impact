require 'open-uri'
require 'json'
load File.dirname(__FILE__) + '/model.rb'

module Github
  BASE_URL = "http://github.com/api/v2/json"

  include Model

  hostname = 'localhost'
  database = 'datasets'
  Mongoid.database = Mongo::Connection.new(hostname).db(database)

  def self.get_info_from_repository repo
    url = BASE_URL + "/repos/show/#{user}" #FIXME
    #TODO: Finish this
  end

  def self.save_user user
    include Model
    url = BASE_URL + "/user/show/#{user}"
    begin
      opened_url = open(url)
    rescue
      false
    else
      user_json = JSON.parse(opened_url.read)["user"]
      u = User.new(username: user,
                   fullname: user_json["name"],
                   organization_id: 1,
                   email: user_json["email"]
                  )
      u.save
    end
  end

  def self.commits_from user, repository
    url = BASE_URL + "/commits/list/#{user}/#{repository}/master"
    begin
      opened_url = open url
    rescue
      []
    else
      JSON.parse(opened_url.read)["commits"].collect do |commit|
        c = Commit.new(sha: commit["id"],
                       author: user,
                       repo: repository,
                       url: commit["url"],
                       commited_at: commit["committed_date"],
                       message: commit["message"]
                      )
        c.save
        c.id
      end
    end
  end

  def self.repositories_from user
    url = BASE_URL + "/repos/show/#{user}"
    begin
      opened_url = open(url)
    rescue
      []
    else
      JSON.parse(opened_url.read)["repositories"].collect { |repo|
        if repo["fork"] == false
          r = Repo.new(name: repo["name"],
                       type: "github",
                       owner: user,
                       commits: commits_from(user, repo["name"])
                       )
          r.save
          r.id
        end
      }.compact
    end
  end

  # Fetches the public_members for a given organization.
  def self.save_members_from org
    url = BASE_URL + "/organizations/#{org}/public_members"
    begin
      opened_url = open(url)
    rescue
      false
    else
      JSON.parse(open(url).read)["users"].collect do |user|
        u = User.new(username: user["login"],
                     fullname: user["user"],
                     organization_id: 1,
                     start_at: user["created_at"],
                     repos: repositories_from(user["login"])
                     )
        u.save
      end
    end
  end

  # Fetches the public_repository for a given organization.
  def self.save_repositories_from org
    url = BASE_URL + "/organizations/#{org}/public_repositories"
    JSON.parse(open(url).read)["repositories"].collect do |repo|
      r = Repo.new(repo)
      r.save
    end
  end

end
