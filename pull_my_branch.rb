require 'sinatra'
require 'json'

module Views
  TEMPLATES = {
    index: <<ERB
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <title>Pull my branch</title>
          <style>
            form label { float: left; }
          </style>
        </head>
        <body>
          <h1>Pull my branch</h1>

          <p>
            <a href="/pull" title="Pull from origin">
              Pull from origin
            </a>
          </p>

          <p>
            <a href="/ls-remote" title="Update remote branches">
              Refresh list of branches from origin
            </a>
          </p>

          <h3>Currently on branch <%= Git::current_branch %></h3>

          <p>
            <form method="post" action="/branch">
              <label for="branch_selector">
                Change to a different branch
              </label>
              <select size="20" id="branch_selector" name="branch">
                <% @branches.each do |branch| %>
                  <option value="<%= branch %>"><%= branch %></option>
                <% end %>
              </select>
              <button type="submit">Switch branch</button>
            </form>
          </p>
        </body>
      </html>
ERB
  }

  def self.get(template)
    TEMPLATES[template]
  end
end

module Git
  def self.remote_branches
    `git branch -a`.split(/\n/)
      .select { |branch| branch.include?('remotes/origin') }
      .reject { |branch| branch.include?('origin/HEAD') }
      .map { |branch| branch.match(/[^\/]+$/)[0] }
  end

  def self.reset_from_origin
    `git reset --hard origin/#{ self.current_branch }`
  end

  def self.change_branch(target)
    if !self.remote_branches.include?(target)
      p "Error: #{ target } does not exist. Cannot change branch."
      return
    end

    `git checkout #{ target }`
    self.reset_from_origin()
  end

  def self.fetch
    `git fetch --all`
  end

  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end
end

class App < Sinatra::Base
  include Views

  set :bind, '0.0.0.0'

  get '/' do
    @branches = Git::remote_branches()
    erb Views.get(:index)
  end

  get '/pull' do
    Git::fetch()
    Git::reset_from_origin()
    redirect to('/')
  end

  get '/ls-remote' do
    Git::fetch()
    redirect to('/')
  end

  post '/hook' do
    payload = JSON.parse(params[:payload])
    branch  = payload['ref'].match(/[^\/]+$/)[0]

    Git::reset_from_origin() if branch.eql?(Git::current_branch())
    redirect to('/')
  end

  post '/branch' do
    Git::change_branch(params[:branch])
    redirect to('/')
  end
end

App.run!
