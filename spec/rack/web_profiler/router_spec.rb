require "spec_helper"
require "rack/lint"
require "rack/mock"

describe Rack::WebProfiler::Router do
  it "load the profiler toolbar corectly" do
    app = ->(_env) { [200, { "Content-Type" => "text/html" }, "<html><body></body></html>"] }
    status, headers, _body = Rack::WebProfiler.new(app).call(
      Rack::MockRequest.env_for()
    )

    expect(status).to be 200
    expect(headers["X-RackWebProfiler-Url"]).not_to be nil

    status, headers, _body = Rack::WebProfiler.new(app).call(
      Rack::MockRequest.env_for(Rack::WebProfiler::Router.url_for_toolbar(headers["X-RackWebProfiler-Token"]))
    )

    expect(headers["X-RackWebProfiler-Token"]).to be nil
    expect(status).to be 200
  end

  it "match profiler /{:token} request" do
    app = ->(_env) { [200, { "Content-Type" => "text/html" }, "<html><body></body></html>"] }
    status, headers, _body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for())

    expect(status).to be 200
    expect(headers["X-RackWebProfiler-Token"]).not_to be nil

    url = Rack::WebProfiler::Router.url_for_profiler(headers["X-RackWebProfiler-Token"])
    status, headers, _body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for(url))

    expect(headers["X-RackWebProfiler-Token"]).to be nil
    expect(status).to be 200
  end

  it "match profiler / request" do
    app = ->(_env) { [200, { "Content-Type" => "text/html" }, "<html><body></body></html>"] }
    Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for())

    url = Rack::WebProfiler::Router.url_for_profiler
    status, headers, _body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for(url))

    expect(status).to be 200
    expect(headers["X-RackWebProfiler-Token"]).to be nil
  end

  # it "match profiler /clean request" do
  #   app = lambda { |env| [200, {"Content-Type" => "text/html"}, "<html><body></body></html>"] }
  #   url = Rack::WebProfiler::Router.url_for_clean_profiler
  #   status, headers, body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for(url))
  #   expect(headers["X-RackWebProfiler-Token"]).to be nil
  #   expect(status).to be 302
  # end

  it "returns a 404 on unknown profiler route" do
    app = ->(_env) { [200, { "Content-Type" => "text/html" }, "<html><body></body></html>"] }
    url = Rack::WebProfiler::Router.url_for_profiler("unexistantprofilertoken")
    status, _headers, _body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for(url))

    expect(status).to be 404
  end
end
