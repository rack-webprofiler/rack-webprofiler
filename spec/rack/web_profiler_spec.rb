require "spec_helper"
require "rack/lint"
require "rack/mock"

describe Rack::WebProfiler do
  it "has a version number" do
    expect(Rack::WebProfiler::VERSION).not_to be nil
  end

  it "does not return the profiler if request not html" do
    app = ->(_env) { [200, { "Content-Type" => "text/plain" }, "Hello, World!"] }
    status, headers, _body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for())

    expect(status).to be 200
    expect(headers["X-RackWebProfiler-Token"]).not_to be nil
    expect(headers["X-RackWebProfiler-Url"]).not_to be nil
  end

  it "does return the profiler if request html" do
    app = ->(_env) { [200, { "Content-Type" => "text/html" }, "<html><body></body></html>"] }
    status, headers, body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for())

    expect(status).to be 200
    expect(headers["X-RackWebProfiler-Token"]).not_to be nil
    expect(headers["X-RackWebProfiler-Url"]).not_to be nil
    body.each do |str|
      expect(str).not_to be "<html><body></body></html>"
    end
  end

  it "works when the reponse body is an Array" do
    app = ->(_env) { [200, { "Content-Type" => "text/html" }, ["<html><body>", "</body></html>"]] }
    status, headers, body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for())

    expect(status).to be 200
    expect(headers["X-RackWebProfiler-Token"]).not_to be nil
    expect(headers["X-RackWebProfiler-Url"]).not_to be nil
    body.each do |str|
      expect(str).not_to be "<html><body></body></html>"
    end
  end

  it "works with differents HTTP status" do
    [200, 201, 301, 302, 400, 401, 403, 404, 500].each do |http_status|
      app = ->(_env) { [http_status, { "Content-Type" => "text/html" }, "<html><body></body></html>"] }
      status, headers, _body = Rack::WebProfiler.new(app).call(Rack::MockRequest.env_for())

      expect(status).to be http_status
      expect(headers["X-RackWebProfiler-Token"]).not_to be nil
      expect(headers["X-RackWebProfiler-Url"]).not_to be nil
    end
  end
end
