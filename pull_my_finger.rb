require 'sinatra'

class Views
  attr_reader :index

  def initialize
    @index = <<ERB
      <!DOCTYPE html>
      <html lang="en">
        <head><title>Pull my branch</title></head>
        <body>Hello world</body>
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