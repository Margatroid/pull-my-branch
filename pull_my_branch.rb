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

class App < Sinatra::Base
  include Views

  get '/' do
    erb Views.get(:index)
  end
end

App.run!