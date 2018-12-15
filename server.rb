require 'sinatra/activerecord'
require 'sinatra'

enable :sessions

configure :development do
  set :database, "sqlite3:database.sqlite3"
end

configure :production do
  set :database, ENV["DATABASE_URL"]
end

# if ENV['RACK_ENV'] == 'development'
#   ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
# else
#   set :database, {adapter: 'sqlite3', database: 'database.sqlite3'}
# end

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

# before ['/posts/new', '/login', '/users/new'] do
# if session[:user_id] != nil
#   redirect '/'
# end
# end

get '/' do
  erb :home
end

####Sign in #####

get '/login' do
  erb :'/users/login'
end

post '/login' do
  user = User.find_by(username: params['username'])
  if user != nil
    if user.password == params['password']
      session[:user_id] = user.id
      redirect "/users/#{user.id}"
    end
  end
end

####CREATE ACCOUNT####

get "/users/new" do
  if session['user_id'] != nil
    p "Signed In"
    redirect "/"
  else
  erb :"/users/new"
end
end

post '/users/new' do
  @user = User.new(name: params['name'], username: params['username'], birthday: params['birthday'], email: params['email'], password: params['password'])
  @user.save
  session[:user_id] = @user.id
  redirect "/users/#{@user.id}"
end

  get "/users/:id" do
    @user = User.find_by(params['id'])
    erb :"/users/show"
  end

  get '/users/?' do
    @users = User.all
    erb :'/users/show'
  end

  post "/users/:id" do
      @user = User.find(session['user_id'])
      @user.destroy
      @user.save
      session["user_id"] = nil
      redirect "/"
  end

  get '/posts/new' do
    if session[:user_id] == nil
      puts "You Need To Be Logged In"
      redirect '/'
    end
    erb :'/posts/new'
  end

  get '/posts/?' do
    @posts =Post.all.reverse
    erb :'posts/timeline'
  end

  post '/posts/new' do
    puts "Posted"
    @post = Post.new(title: params['title'], content: params['content'], username: params['username'])
    @post.save
    redirect :"users/#{session["user_id"]}"
  end


  get '/posts/:id' do
    @post = Post.find_by(params['id'])
    if post.user_id == session[:user_id]
    @post.destroy
    redirect :"users/#{session["user_id"]}"

  end

  post "/logout" do
  session[:user_id] == nil
  redirect '/'
end
end


