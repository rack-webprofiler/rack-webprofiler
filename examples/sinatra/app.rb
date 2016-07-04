require "bundler/setup"
require "rack/webprofiler"
require "rack"
require "sinatra"

class App < Sinatra::Base
  use Rack::WebProfiler, tmp_dir: File.expand_path("../tmp", __FILE__)

  get "/" do
    erb "Hello World!", layout: TEMPLATE
  end

  get "/without_profiler" do
    erb "Hello World!"
  end

  get "/500" do
    "Hello World!" if hello == world
    erb ""
  end

  TEMPLATE = <<-HTML
  <html>
  <head>
    <title>Rack WebProfiler test — Sinatra</title>
  </head>
  <body>
    <p>
      <a href="./">text/html page</a>
      - <a href="./without_profiler">text/plain page</a>
      - <a href="./500">500 page</a>
    </p>
    <%= yield %>
  </body>
  </html>
  HTML
end
