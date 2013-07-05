require 'sinatra'

module Views
  TEMPLATES = {
    index: <<ERB
      <!DOCTYPE html>
      <html lang="en">
        <head><title>Pull my branch</title></head>
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
    branches        = `git branch -a`.split(/\n/).map { |line| line.strip }
    branches.select { |branch_name| branch_name.include?('remotes/origin') }
  end
end

class App < Sinatra::Base
  include Views

  set :bind, '0.0.0.0'

  get '/' do
    p 'Hello World'
    erb Views.get(:index)
  end

  post 'hook' do
    push = JSON.parse(params[:payload])
    data = "Inspecting #{ push.inspect }"
    p data
    data
  end
end

#App.run!
