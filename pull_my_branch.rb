require 'sinatra'

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
  def self.get_remote_branches
    branches = `git branch -a`.split(/\n/).map { |line| line.strip }
    remotes  = branches.select { |branch| branch.include?('remotes/origin') }
                 .reject { |branch| branch.include?('origin/HEAD') }
  end
end

class App < Sinatra::Base
  include Views

  set :bind, '0.0.0.0'

  get '/' do
    @branches = Git::get_remote_branches
    erb Views.get(:index)
  end

  post 'hook' do
    push = JSON.parse(params[:payload])
    data = "Inspecting #{ push.inspect }"
    p data
    data
  end
end

App.run!
