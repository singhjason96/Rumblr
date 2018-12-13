require 'sinatra/activerecord'
require 'sinatra'
require 'sqlite3'
enable :sessions

if ENV['RACK_ENV'] == 'development'
set :database, {adapter: 'sqlite3', database: 'database.sqlite3'}
else
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
end

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end


get '/' do
  erb :'/users/home'

end

get '/posts/new' do
  if session['user_id'] == nil
    puts "Need to sign in"
    redirect '/'
  end
    erb :'/posts/new'
end





post '/posts/new' do
  puts "Posted"
  @post = Post.new(title: params['title'], username: params['username'], content: params['content'])
  @post.save
   p @post
  redirect "/posts/#{@post.id}"
end

get '/posts/:id' do
  @post = Post.find(params['id'])
  erb :'/posts/show'
end

get '/login' do
   erb :'/users/login'
end

post '/login' do
  user = User.find_by(username: params['username'])
  if user != nil
    if user.password == params['password']
      session[:user_id] = user.id
      # redirect "/users/#{user.id}"
      redirect "/posts/new"
      end
    end
  end


get '/users/new' do
  erb :'/users/new'
end

get '/users/:id' do
  @user = User.find(params['id'])
  erb :'users/show'
end

post '/users/new' do
  @user = User.new(name: params['name'], username: params['username'], birthday: params['birthday'], email: params['email'], password: params['password'])
  @user.save
  session[:user_id] = @user.id
  redirect "/users/#{@user.id}"
end
