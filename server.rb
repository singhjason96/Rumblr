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

#Root
get '/' do
  if session['user_id'] != nil 
    redirect '/posts'
  else
  erb :home
  end
end



####Sign in #####

#New Session
get '/login' do
  erb :'/users/login'   
end

#Create Session
post '/login' do
  @user = User.find_by(username: params['username'])
  if @user != nil 
    p @user
    if @user.password == params['password']
      session['user_id'] = @user.id
      redirect "/users/#{@user.id}"
    end
  end
end

#Delete Session
get '/logout' do
  session['user_id'] = nil
  session[:user_id] = nil
  redirect '/'
end

#New Users
get "/users/new" do
  if session['user_id'] != nil
    p "Signed In"
    redirect "/"
  else
  erb :"/users/new"
end
end

#Creates User
post '/users/new' do
  @user = User.new(name: params['name'], username: params['username'], birthday: params['birthday'], email: params['email'], password: params['password'])
  @user.save
  session['user_id'] = @user.id
  redirect "/users/#{@user.id}"
end

#User Show
  get "/users/:id" do
    @user = User.find(params[:id])
    erb :"/users/show"
  end

  #Index Users
  get '/users/?' do
    @users = User.all
    erb :'/users/show'
  end

  #Deletes User
  post "/users/:id" do
      @user = User.find(session['user_id'])
      @user.destroy
      session["user_id"] = nil
      redirect "/"
  end

  #Edit Post
  get '/posts/:id/edit' do
    @post = Post.find(params[:id])
    erb :'posts/edit'
 
  end

   ####New Post Page####
   get '/posts/new' do
    if session['user_id'] == nil
      puts "You Need To Be Logged In"
      redirect '/'
    end
    erb :'/posts/new'
  end

#Show Post
get '/posts/:id' do
  @post = Post.find(params[:id])
  @user = User.find(session['user_id'])
  @canedit = @post.username == @user.username
  puts @canedit
  puts @user.username
  puts @post.username
  erb :'posts/show'
end

 



  ####Index Posts####
  get '/posts' do
    @posts =Post.all.reverse
    erb :'posts/timeline'
  end

  ###Creates Posts####
  post '/posts/new' do
    puts "Posted"
    @post = Post.new(title: params['title'], content: params['content'], username: params['username'])
    @post.save
    redirect "/users/#{session["user_id"]}"
  end

  

  ###Deletes Post#####
  delete '/posts/:id' do
    @post = Post.find_by(params['id'])
    if post.user_id == session['user_id']
    @post.destroy
    redirect "/users/#{session["user_id"]}"
    else 
      redirect '/'
    end

  end

  
  ####Updates post####
  put '/posts/:id' do 
    @post = Post.find(params[:id])
    @post.update(title: params[:title], content: params[:content])
    @post.save
    redirect "/posts/#{@post.id}"
  end

  

  



