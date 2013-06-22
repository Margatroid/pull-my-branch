require 'sinatra'

class Views
  attr_reader :index

  def initialize
    @index = <<ERB
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
  end
end

class App < Sinatra::Base
  views = Views.new()

  get '/' do
    erb views.index
  end
end

App.run!