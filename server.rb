require 'sinatra/activerecord'
require 'sinatra'
require 'sqlite3'
enable :sessions

if ENV['RACK_ENV'] == 'development'
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  set :database, {adapter: 'sqlite3', database: 'database.sqlite3'}
end

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

get "/users/new" do
  if session['user.id'] != nil
    p "Signed In"
    redirect "/"
  end
  erb :"/users/new"
end

post '/users/new' do
  @user = User.new(name: params['name'], username: params['username'], birthday: params['birthday'], email: params['email'], password: params['password'])
  @user.save
  session[:user_id] = @user.id
  redirect "/users/#{@user.id}"
end

  get "/users/:id" do
    @user = User.find(params['id'])
    @posts = Post.where(user_id: params['id'])
    erb :'/users/show'
  end

  get '/users/?' do
    @users = User.all
    erb :'/users/members'
  end

  post '/users/:id' do
    @user = User.find(params['id'])
    @user.destroy
    redirect '/'
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
    @post = Post.find_by(params['username'])
    @post.destroy
    redirect :"users/#{session["user_id"]}"

  end

  post "/logout" do
  session[:user_id] == nil
  redirect '/'
end

# get '/' do
#   session[:user_id] == nil
#   erb :'/users/home'
#
# end
#
# post '/login' do
#   user = User.find_by(username: params['username'])
#   if user != nil
#     if user.password == params['password']
#       session[:user_id] = user.id
#       # redirect "/users/#{user.id}"
#       redirect "/posts/new"
#     else
#       redirect "/users/new"
#     end
#   end
# end
#
# get '/users/new' do
#   erb :'/users/new'
# end
#
#
#
#   post '/users/new' do
#     @user = User.new(name: params['name'], username: params['username'], birthday: params['birthday'], email: params['email'], password: params['password'])
#     @user.save
#     session[:user_id] = @user.id
#     redirect "/users/#{@user.id}"
#   end
#
# get '/users/:id' do
#   @user = User.find(params['id'])
#   @posts = Post.all
#   erb :'users/show'
# end
#
# get '/users/?' do
#   @users = User.all
#   erb :'/users/home'
# end
#
# post '/posts/new' do
#   puts "Posted"
#   @post = Post.new(title: params[:title], username: params[:username], content: params[:content], user_id: session[:user_id])
#   @post.save
#   redirect "/posts/#{@post.id}"
# end
#
# get '/posts/new' do
#   if session[:user_id] == nil
#     puts "Need to sign in"
#     redirect '/'
#   end
#   erb :'/posts/new'
# end
#
#
# get '/posts/:id' do
#   @post = Post.find(params['id'])
#   erb :"/posts/show"
# end
#
# get '/posts/?' do
#   @posts = Post.all
#   erb :'posts/timeline'
# end
#
#
#
# get '/login' do
#   erb :'/users/login'
# end
