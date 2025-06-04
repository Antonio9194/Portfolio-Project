# frozen_string_literal: true

require 'dotenv/load'
require 'securerandom'
require 'sinatra'
require 'json'

enable :sessions
set :session_secret, ENV['SESSION_SECRET']

set :public_folder, File.expand_path('../public', __FILE__)
set :views, File.expand_path('views', __dir__)

# Temporary in-memory store
projects = []

get '/' do
  erb :index
end

get '/set_guest' do
  session[:allowed_guest] = true
  redirect '/guest'
end

get '/guest' do
  if session[:allowed_guest]
    erb :guest
  else
    redirect '/'
  end
end

post '/login' do
  if params[:password] == ENV['OWNER_PASSWORD']
    session[:authorized] = true
    redirect '/owner'
  else
    redirect '/'
  end
end

get '/owner' do
  redirect '/' unless session[:authorized]
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
