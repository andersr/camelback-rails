class GetAssignments
  attr_reader :client

  def initialize
    authenticate
  end

  def call
    insert_assignments
  end

  def authenticate
    @client = Octokit::Client.new \
      :access_token => GITHUB_PERSONAL_ACCESS_TOKEN

    if authenticated?
      puts "Authenticated as #{@client.user.login}!"
    else
      raise GithubAuthError
    end
  end

  def authenticated?
    @client.user_authenticated?
  end

  def assignments
    @client.org_repos('flatiron-school', :type => 'private')
  end

  def insert_assignments
    assignments.each do |assignment|
      a = Assignment.create(
        :name => assignment.name,
        :full_name => assignment.full_name,
        :web_url => repo_url(assignment.full_name),
        :github_created_at => assignment.created_at,
        :clone_url => assignment.rels[:ssh].href
        )
      puts "Saving #{assignment.name}."
      insert_forks(a)
      a.save
    end
    Assignment.initial_generate_tags
  end

  def repo_url(full_name)
    "https://github.com/#{full_name}"
  end

  def insert_forks(assignment)
    forks_array = client.forks(assignment.full_name)
    forks_array.each do |fork|
      # binding.pry
      s = Student.find_or_create_by(:name => fork.owner.login)
      h = Homework.create({
        :name => fork.name,
        :full_name => fork.full_name,
        :student_id => s.id,
        :assignment_id => assignment.id,
        :web_url => fork.rels[:html].href,
        :clone_url => fork.rels[:ssh].href,
        :gravatar_url => "https://1.gravatar.com/avatar/#{fork.owner.gravatar_id}.png"
      })
      puts "  Saving #{h.full_name}."
    end
  end
end

class GithubAuthError < Exception
end
