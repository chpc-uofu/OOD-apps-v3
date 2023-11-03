require 'sinatra'
require 'ood_core'
require 'rexml/document'
require 'open3'
require 'pathname'

set :erb, :escape_html => true

if development?
  require 'sinatra/reloader'
end

helpers do
  def dashboard_title
    "Open OnDemand"
  end

  def dashboard_url
    "/pun/sys/dashboard/"
  end

  def public_url
     ENV['OOD_PUBLIC_URL'] || "/public"
  end

  def title
    "Kingspeak Node Status"
  end
end

# Define a route at the root '/' of the app.
get '/' do
  # Render the view
  erb :index
end
