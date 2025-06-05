# frozen_string_literal: true

require 'dotenv/load'
require 'securerandom'
require 'sinatra'
require 'json'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'])

unless DB.table_exists?(:projects)
  DB.create_table :projects do
    primary_key :id
    String :title, null: false
    String :description, text: true, null: false
    String :link
    String :github
  end
end

class Project < Sequel::Model(:projects)
end

enable :sessions
set :session_secret, ENV['SESSION_SECRET']

set :public_folder, File.expand_path('../public', __FILE__)
set :views, File.expand_path('views', __dir__)

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

# Get all projects
get '/projects' do
  content_type :json
  Project.all.to_a.to_json
end

# Add a new project
post '/projects' do
  request.body.rewind
  data = JSON.parse(request.body.read)

  project = Project.create(
    title: data['title'],
    description: data['description'],
    link: data['link'],
    github: data['github']
  )

  status 201
  project.to_json
end
