# frozen_string_literal: true

require 'securerandom'
require 'sinatra'
require 'json'

set :public_folder, File.expand_path('../public', __FILE__)
set :views, File.expand_path('views', __dir__)

# Temporary in-memory store
projects = []

get '/' do
  erb :index
end

get '/guest' do
  erb :guest
end

get '/owner' do
  erb :owner
end

# API to get all projects (for guest page)
get '/projects' do
  content_type :json
  projects.to_json
end

# API to add a new project (for owner page)
post '/projects' do
  request.body.rewind
  data = JSON.parse(request.body.read)

  new_project = {
    id: SecureRandom.uuid,
    title: data['title'],
    description: data['description'],
    link: data['link'],
    github: data['github']
  }

  projects << new_project
  status 201
  new_project.to_json
end
