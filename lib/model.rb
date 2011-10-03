module Model

require 'mongoid'

  class Repo
    include Mongoid::Document
    
    field :name, type: String
    field :owner, type: String
    field :type, type: String
    field :branches, type: Array, default: ['master']
    field :commits, type: Array # [commit.id, commit.id...]
    field :bugs, type: Array # [Bug.id, type: Bug.id...]

    index :name
    index :owner
  end

  class Commit
    include Mongoid::Document
    
    field :sha, type: Integer
    field :url, type: String
    field :repo, type: String
    field :author, type: String # User.id
    field :commited_at, type: Time

    index :sha, unique: true
  end

  class Bug
    include Mongoid::Document
    
    field :bug_id, type: Integer
    field :project, type: String
    field :title, type: String
    field :created_by, type: String # User.id
    field :assigned_to, type: String # User.id
    field :reported_at, type: Time
    field :status, type: String

    index :project
    key :project, :bug_id
  end

  class User
    include Mongoid::Document
    
    field :id, type: Integer
    field :organization_id, type: Integer
    field :username, type: String
    field :fullname, type: String
    field :email, type: String
    field :start_at, type: Time
    field :active, type: Boolean
    field :repos, type: Array # [Repo.id, Repo.id...]
    field :bugs, type: Array # [Bug.id, type: Bug.id...]

    index :username, unique: true
  end

  class Organization
    include Mongoid::Document
    
    field :id, type: Integer
    field :name, type: String
    field :repos, type: Array # [Repo.id, Repo.id...]
    field :members, type: Array # [User.id, User.id...]

    index :name, unique: true
  end

end
